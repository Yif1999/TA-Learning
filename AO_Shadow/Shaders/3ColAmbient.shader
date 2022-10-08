Shader "Custom/3ColAmbient"
{
    Properties
    {
        _Occlusion("AO贴图",2d)="white"{}
        _EnvUpCol("环境上",color)=(1.0,1.0,1.0,1.0)
        _EnvSideCol("环境侧",color)=(0.5,0.5,0.5,0.5)
        _EnvDownCol("环境下",color)=(0.0,0.0,0.0,0.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Name "FORWARD"
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            uniform float3 _EnvUpCol;
            uniform float3 _EnvSideCol;
            uniform float3 _EnvDownCol;
            uniform sampler2D _Occlusion;

            struct VertexInput
            {
                float4 vertex:POSITION;
                float4 normal:NORMAL;
                float2 uv0:TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 pos:SV_POSITION;
                float3 nDirWS:TEXCOORD0;
                float2 uv:TEXCOORD1;
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.nDirWS=UnityObjectToWorldNormal(v.normal);
                o.uv=v.uv0;
                return o;
            }

            float4 frag(VertexOutput i):COLOR
            {
                float3 nDir=i.nDirWS;
                float upMask=max(0.0,nDir.g);
                float downMask=max(0.0,-nDir.g);
                float sideMask=1.0-upMask-downMask;
                float3 envCol=_EnvUpCol*upMask+_EnvSideCol*sideMask+_EnvDownCol*downMask;
                float occlusion=tex2D(_Occlusion,i.uv);
                float3 finalRGB=envCol*occlusion;
                return float4(finalRGB,1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
