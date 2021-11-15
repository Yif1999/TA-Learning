Shader "Custom/3ColShadow"
{
    Properties
    {
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
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0

            uniform float3 _EnvUpCol;
            uniform float3 _EnvSideCol;
            uniform float3 _EnvDownCol;
            uniform sampler2D _Occlusion;

            struct VertexInput
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct VertexOutput
            {
                float4 pos:SV_POSITION;
                float3 nDirWS:NORMAL;
                LIGHTING_COORDS(0,1)
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.nDirWS=UnityObjectToWorldNormal(v.normal);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            float4 frag(VertexOutput i):COLOR
            {
                float3 nDir=i.nDirWS;
                float upMask=max(0.0,nDir.g);
                float downMask=max(0.0,-nDir.g);
                float sideMask=1.0-upMask-downMask;
                float3 envCol=_EnvUpCol*upMask+_EnvSideCol*sideMask+_EnvDownCol*downMask;
                float shadow=LIGHT_ATTENUATION(i);
                float3 finalRGB=envCol*shadow;
                return float4(finalRGB,1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
