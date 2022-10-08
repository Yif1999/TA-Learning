Shader "Unlit/NormalTex"
{
    Properties
    {
        _NormalMap ("Texture", 2D) = "bump" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            uniform sampler2D _NormalMap;

            struct VertexInput
            {
                float4 vertex : POSITION;
                float4 normal:NORMAL;
                float4 tangent:TANGENT;
                float2 uv0 : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 pos:SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 nDirWS:TEXCOORD1;
                float3 tDirWS:TEXCOORD2;
                float3 bDirWS:TEXCOORD3;
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv0;
                o.nDirWS=UnityObjectToWorldNormal(v.normal);
                o.tDirWS=normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
                o.bDirWS=normalize(cross(o.nDirWS,o.tDirWS)*v.tangent.w);
                return o;
            }

            float4 frag (VertexOutput i) : COLOR
            {
                float3 nDirTS=UnpackNormal(tex2D(_NormalMap,i.uv0));
                float3x3 TBN=float3x3(i.tDirWS,i.bDirWS,i.nDirWS);
                float3 nDirWS=normalize(mul(nDirTS,TBN));
                float3 lDir=_WorldSpaceLightPos0.xyz;
                float nDotl=dot(nDirWS,lDir);
                float lambert=max(0.0,nDotl)*0.5+0.5;
                return float4(lambert,lambert,lambert,1.0);
            }
            ENDCG
        }
    }
}
