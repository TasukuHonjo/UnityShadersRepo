Shader "Custom/GenericFresnel"
{
    Properties
    {
        _BaseMap ("Base Texture", 2D) = "white" {}
        
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
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
                float3 normalWS    : TEXCOORD0;
                float3 viewDirWS   : TEXCOORD1;
                float2 uv          : TEXCOORD2;
            };

            sampler2D _BaseMap;
            float4 _BaseMap_ST;

            float4 _FresnelColor;
            float _FresnelPower;
            float _FresnelIntensity;
            float _Opacity;

            Varyings vert (Attributes v)
            {
                Varyings o;

                float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);

                o.positionHCS = TransformWorldToHClip(positionWS);
                o.normalWS = normalize(TransformObjectToWorldNormal(v.normalOS));
                o.viewDirWS = normalize(GetWorldSpaceViewDir(positionWS));
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);

                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                half4 baseCol = tex2D(_BaseMap, i.uv);

                // フレネル計算
                float fresnel = 1.0 - saturate(dot(i.viewDirWS, i.normalWS));
                fresnel = pow(fresnel, _FresnelPower);

                // 強度適用
                float3 fresnelEffect = _FresnelColor.rgb * fresnel * _FresnelIntensity;

                float3 finalColor = baseCol.rgb + fresnelEffect;

                return half4(finalColor, baseCol.a * _Opacity);
            }

            ENDHLSL
        }
    }
}