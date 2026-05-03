Shader "Custom/DissolveShader"
{
    Properties
    {
        _BaseMap ("Base Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        
        _DissolveAmount ("Dissolve Amount", Range(0,1)) = 0
        _EdgeWidth ("Edge Width", Range(0.001,0.2)) = 0.05
        
        _EdgeColor ("Edge Color", Color) = (1,0.5,0,1)
        _EdgeEmission ("Edge Emission", Range(0,10)) = 2
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Pass
        {
            Name "ForwardPass"
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
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _BaseMap;
            sampler2D _NoiseTex;

            float4 _BaseMap_ST;
            float4 _NoiseTex_ST;

            float _DissolveAmount;
            float _EdgeWidth;

            float4 _EdgeColor;
            float _EdgeEmission;

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                float2 uv = i.uv;

                // ベースカラー
                half4 baseCol = tex2D(_BaseMap, uv);

                // ノイズ取得
                float noise = tex2D(_NoiseTex, uv).r;

                // ディゾルブ判定
                float dissolve = noise - _DissolveAmount;

                // エッジ判定
                float edge = smoothstep(0, _EdgeWidth, dissolve);

                // 完全に消える部分
                clip(dissolve);

                // エッジ発光
                float edgeMask = 1.0 - edge;
                float3 emission = _EdgeColor.rgb * edgeMask * _EdgeEmission;

                return half4(baseCol.rgb + emission, baseCol.a);
            }
            ENDHLSL
        }
    }
}