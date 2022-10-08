Shader "Custom/OldSchool"
{
    Properties
    {
        _MainCol("Color",color)=(1.0,1.0,1.0,1.0)
        _SpecularPow("Power",range(1,90))=30
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            uniform fixed3 _MainCol;
            uniform float _SpecularPow;

            struct VertexInput
            {
                float4 vertex:POSITION;
                float4 normal:NORMAL;
            };

            struct VertexOutput
            {
                float4 posCS:SV_POSITION;
                float4 posWS:TEXCOORD0;
                float3 nDirWS:TEXCOORD1;
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.posCS=UnityObjectToClipPos(v.vertex);
                o.posWS=mul(unity_ObjectToWorld,v.vertex);
                o.nDirWS=UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag(VertexOutput i):COLOR
            {
                float3 nDir=i.nDirWS;
                float3 lDir=_WorldSpaceLightPos0.xyz;
                float3 vDir=normalize(_WorldSpaceCameraPos.xyz-i.posWS);
                float3 rDir=reflect(-lDir,nDir);
                float nDotl=dot(i.nDirWS,lDir);
                float vDotr=dot(vDir,rDir);
                float lambert=max(0.0,nDotl)*0.5+0.5;
                float Phong=pow(max(0.0,vDotr),_SpecularPow);
                float3 finalRGB=_MainCol*lambert+Phong;
                return float4(finalRGB,1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
