Shader "Custom/AdvancedDissolve"
{
    Properties
    {
        _BaseMap ("Base", 2D) = "white" {}
        
        _NoiseTex1 ("Noise Large", 2D) = "white" {}
        _NoiseTex2 ("Noise Detail", 2D) = "white" {}

        _Dissolve ("Dissolve", Range(0,1)) = 0
        
        _EdgeWidth ("Edge Width", Range(0.001,0.2)) = 0.08
        
        _EdgeColor1 ("Edge Inner", Color) = (1,0.3,0,1)
        _EdgeColor2 ("Edge Outer", Color) = (1,1,0,1)
        
        _Emission ("Emission", Range(0,10)) = 3
        _ScrollSpeed ("Scroll Speed", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

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
            sampler2D _NoiseTex1;
            sampler2D _NoiseTex2;

            float _Dissolve;
            float _EdgeWidth;
            float _Emission;
            float _ScrollSpeed;

            float4 _EdgeColor1;
            float4 _EdgeColor2;

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
                o.uv = v.uv;
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                float2 uv = i.uv;

                half4 baseCol = tex2D(_BaseMap, uv);

                // スクロール付きノイズ
                float2 scrollUV = uv + float2(_Time.y * _ScrollSpeed, 0);

                float n1 = tex2D(_NoiseTex1, uv).r;
                float n2 = tex2D(_NoiseTex2, scrollUV * 2).r;

                float noise = lerp(n1, n2, 0.5);

                float d = noise - _Dissolve;

                // エッジ帯
                float edge = smoothstep(0, _EdgeWidth, d);
                float edgeBand = 1.0 - edge;

                clip(d);

                // グラデーションエッジ
                float3 edgeColor = lerp(_EdgeColor1.rgb, _EdgeColor2.rgb, edgeBand);

                float3 emission = edgeColor * edgeBand * _Emission;

                return half4(baseCol.rgb + emission, baseCol.a);
            }
            ENDHLSL
        }
    }
}