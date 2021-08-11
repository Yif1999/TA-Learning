Shader "Custom/CubeMap"
{
    Properties
    {
        _CubeMap("Cube Map",Cube)="gray"{}
        _CubeMapMip("Cube Map Mip",Range(0,7))=0
        _NormalMap("Normal Map",2D)="bump"{}
        _FresnelPow("Fre Pow",Range(0,5))=1
        _EnvSpecInt("Env Light Intensity",Range(0,5))=1
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
            uniform samplerCUBE _CubeMap;
            uniform float _CubeMapMip;
            uniform float _FresnelPow;
            uniform float _EnvSpecInt;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 nDirWS:TEXCOORD1;
                float3 tDirWS:TEXCOORD2;
                float3 bDirWS:TEXCOORD3;
                float3 posWS:TEXCOORD4;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWS=mul(unity_ObjectToWorld,v.vertex);
                o.uv = v.uv;
                o.nDirWS=UnityObjectToWorldNormal(v.normal);
                o.tDirWS=normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
                o.bDirWS=normalize(cross(o.nDirWS,o.tDirWS)*v.tangent.w);
                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {
                float3 nDirTS=UnpackNormal(tex2D(_NormalMap,i.uv));
                float3x3 TBN=float3x3(i.tDirWS,i.bDirWS,i.nDirWS);
                float3 nDirWS=normalize(mul(nDirTS,TBN));
                float3 vDirWS=normalize(_WorldSpaceCameraPos.xyz-i.posWS);
                float3 vrDirWS=reflect(-vDirWS,nDirWS);
                float vDotn=dot(vDirWS,nDirWS);
                float fresnel=pow(1.0-vDotn,_FresnelPow);
                float3 cubemap=texCUBElod(_CubeMap,float4(vrDirWS,_CubeMapMip));
                float3 envSpecLight=cubemap*fresnel*_EnvSpecInt;
                return float4(envSpecLight,1.0);
            }
            ENDCG
        }
    }
}
