Shader "Custom/OutlineShader"
{
    Properties
    {
        _BaseMap ("Base Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)

        _ShadowThreshold ("Shadow Threshold", Range(0,1)) = 0.5
        _ShadowSmooth ("Shadow Smooth", Range(0.001,0.2)) = 0.05

        _OutlineColor ("Outline Color", Color) = (1,0,0,1)
        _OutlineWidth ("Outline Width", Range(0,5)) = 1

        _FresnelPower ("Fresnel Power", Range(1,8)) = 4
        _FresnelThreshold ("Fresnel Threshold", Range(0,1)) = 0.6
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        // =========================================
        // ① 隠れてる時だけ表示されるアウトライン（修正版）
        // =========================================
        Pass
        {
            Name "OutlineBehind"

            Cull Front
            ZWrite Off
            ZTest Greater
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS    : TEXCOORD0;
                float3 viewDirWS   : TEXCOORD1;
            };

            float _OutlineWidth;
            float4 _OutlineColor;

            float _FresnelPower;
            float _FresnelThreshold;

            Varyings vert (Attributes v)
            {
                Varyings o;

                float3 posWS = TransformObjectToWorld(v.positionOS.xyz);
                float3 normalWS = normalize(TransformObjectToWorldNormal(v.normalOS));

                // ビュー空間へ
                float3 posVS = TransformWorldToView(posWS);
                float3 normalVS = normalize(mul((float3x3)UNITY_MATRIX_V, normalWS));

                // 画面基準で押し出し
                posVS.xy += normalVS.xy * _OutlineWidth * posVS.z * 0.001;

                o.positionHCS = TransformWViewToHClip(posVS);

                // フレネル用
                o.normalWS = normalWS;
                o.viewDirWS = normalize(GetWorldSpaceViewDir(posWS));

                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                // フレネルで輪郭抽出
                float fresnel = 1.0 - saturate(dot(i.viewDirWS, i.normalWS));
                fresnel = pow(fresnel, _FresnelPower);

                // 輪郭だけ残す
                float alpha = smoothstep(_FresnelThreshold, 1.0, fresnel);

                // 完全に不要な部分は捨てる
                clip(alpha - 0.01);

                return float4(_OutlineColor.rgb, alpha);
            }

            ENDHLSL
        }

        // =========================================
        // ② トゥーン本体
        // =========================================
        Pass
        {
            Name "Toon"
            Tags { "LightMode"="UniversalForward" }

            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS    : TEXCOORD0;
                float2 uv          : TEXCOORD1;
            };

            sampler2D _BaseMap;
            float4 _Color;

            float _ShadowThreshold;
            float _ShadowSmooth;

            Varyings vert (Attributes v)
            {
                Varyings o;

                float3 posWS = TransformObjectToWorld(v.positionOS.xyz);

                o.positionHCS = TransformWorldToHClip(posWS);
                o.normalWS = normalize(TransformObjectToWorldNormal(v.normalOS));
                o.uv = v.uv;

                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                Light light = GetMainLight();

                float NdotL = dot(i.normalWS, light.direction);

                float shade = smoothstep(
                    _ShadowThreshold - _ShadowSmooth,
                    _ShadowThreshold + _ShadowSmooth,
                    NdotL
                );

                half4 tex = tex2D(_BaseMap, i.uv) * _Color;

                // 影色（少し暗く）
                float3 shadowCol = tex.rgb * 0.5;

                float3 finalColor = lerp(shadowCol, tex.rgb, shade);

                return half4(finalColor, tex.a);
            }

            ENDHLSL
        }
    }
}