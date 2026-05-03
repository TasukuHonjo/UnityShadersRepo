Shader "Custom/FresnelDissolve"
{
    Properties
    {
        _BaseMap ("Base Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}

        _Dissolve ("Dissolve", Range(0,1)) = 0
        _EdgeWidth ("Edge Width", Range(0.001,0.2)) = 0.05

        _EdgeColor ("Edge Color", Color) = (1,0.5,0,1)
        _EdgeEmission ("Edge Emission", Range(0,10)) = 3

        _FresnelColor ("Fresnel Color", Color) = (0.5,0.8,1,1)
        _FresnelPower ("Fresnel Power", Range(0.5,8)) = 3
        _FresnelIntensity ("Fresnel Intensity", Range(0,5)) = 1

        _Opacity ("Opacity", Range(0,1)) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv          : TEXCOORD0;
                float3 normalWS    : TEXCOORD1;
                float3 viewDirWS   : TEXCOORD2;
            };

            sampler2D _BaseMap;
            sampler2D _NoiseTex;

            float _Dissolve;
            float _EdgeWidth;

            float4 _EdgeColor;
            float _EdgeEmission;

            float4 _FresnelColor;
            float _FresnelPower;
            float _FresnelIntensity;

            float _Opacity;

            Varyings vert (Attributes v)
            {
                Varyings o;

                float3 posWS = TransformObjectToWorld(v.positionOS.xyz);

                o.positionHCS = TransformWorldToHClip(posWS);
                o.uv = v.uv;
                o.normalWS = normalize(TransformObjectToWorldNormal(v.normalOS));
                o.viewDirWS = normalize(GetWorldSpaceViewDir(posWS));

                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                // --- ベース ---
                half4 baseCol = tex2D(_BaseMap, i.uv);

                // --- ノイズ ---
                float noise = tex2D(_NoiseTex, i.uv).r;

                // --- ディゾルブ ---
                float d = noise - _Dissolve;

                // エッジ帯
                float edge = smoothstep(0, _EdgeWidth, d);
                float edgeBand = 1.0 - edge;

                // 消滅
                clip(d);

                // --- フレネル ---
                float fresnel = 1.0 - saturate(dot(i.viewDirWS, i.normalWS));
                fresnel = pow(fresnel, _FresnelPower);

                // 👉 ディゾルブと連動（ここがキモ）
                float fresnelMask = fresnel * edgeBand;

                float3 fresnelCol = _FresnelColor.rgb * fresnelMask * _FresnelIntensity;

                // --- エッジ発光 ---
                float3 edgeEmission = _EdgeColor.rgb * edgeBand * _EdgeEmission;

                // --- 合成 ---
                float3 finalColor = baseCol.rgb + edgeEmission + fresnelCol;

                return half4(finalColor, baseCol.a * _Opacity);
            }

            ENDHLSL
        }
    }
}