Shader "Custom/MyDotaShader"
{
    Properties
    {
        [Header(Parameter)]
        _LightCol("lightCol",color)=(1.0,1.0,1.0)
        _SpecPower("specPower",range(0.0,30.0))=5
        _SpecIntensity("specIntensity",range(0.0,10.0))=5
        _EnvCol("envCol",color)=(1.0,1.0,1.0)
        _EnvDiffInt("envDiffInt",range(0.0,5.0))=0.5
        _EnvSpecInt("envSpecInt",range(0.0,100.0))=100
        _RimCol("rimCol",color)=(1.0,1.0,1.0)
        _RimIntensity("rimIntensity",range(0.0,3.0))=1.0
        _EmitInt("emitInt",range(0.0,10.0))=1.0
        [Header(Texture)]
        _BaseCol("baseCol",2d)="white"{}
        _Alpha("alpha",2d)="white"{}
        _SpecInt("specInt",2d)="black"{}
        _RimInt("rimInt",2d)="black"{}
        _TintMask("tintMask",2d)="black"{}
        _SpecPow("specPow",2d)="black"{}
        _NormTex("normalMap",2d)="bump"{}
        _MetalnessMask("metalMask",2d)="black"{}
        _EmissionMask("emissionMask",2d)="black"{}
        _DiffuseWarpTex("diffWarpTex",2d)="gray"{}
        _FresnelCol("fresnelCol",2d)="gray"{}
        _FresnelRim("fresnelRim",2d)="gray"{}
        _FresnelSpec("fresnelSpec",2d)="gray"{}
        _Cubemap("cubeMap",cube)="_Skybox"{}
        [HideInInspector]
        _Cutoff("Alpha cutoff",range(0,1))=0.5
        [HideInInspector]
        _Color("Main color",color)=(1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Name "FORWARD"
            Tags {"LightMode"="ForwardBase"}
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0

            uniform half3 _LightCol;
            uniform half _SpecPower;
            uniform half _SpecIntensity;
            uniform half3 _EnvCol;
            uniform half _EnvDiffInt;
            uniform half _EnvSpecInt;
            uniform half3 _RimCol;
            uniform half _RimIntensity;
            uniform half _EmitInt;
            uniform sampler2D _BaseCol;
            uniform sampler2D _Alpha;
            uniform sampler2D _SpecInt;
            uniform sampler2D _RimInt;
            uniform sampler2D _TintMask;
            uniform sampler2D _SpecPow;
            uniform sampler2D _NormTex;
            uniform sampler2D _MetalnessMask;
            uniform sampler2D _EmissionMask;
            uniform sampler _DiffuseWarpTex;
            uniform sampler _FresnelCol;
            uniform sampler _FresnelRim;
            uniform sampler _FresnelSpec;
            uniform samplerCUBE _Cubemap;
            uniform half _Cutoff;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWS:texcoord1;
                float3 nDirWS:TEXCOORD2;
                float3 tDirWS:TEXCOORD3;
                float3 bDirWS:TExcoord4;
                LIGHTING_COORDS(5,6)
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv0;
                o.posWS=mul(unity_ObjectToWorld,v.vertex);
                o.nDirWS=UnityObjectToWorldNormal(v.normal);
                o.tDirWS=normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
                o.bDirWS=normalize(cross(o.nDirWS,o.tDirWS)*v.tangent.w);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {   
                //信息准备
                half3 nDirTS=UnpackNormal(tex2D(_NormTex,i.uv0));
                half3x3 TBN=half3x3(i.tDirWS,i.bDirWS,i.nDirWS);
                half3 nDirWS=normalize(mul(nDirTS,TBN));
                half3 vDirWS=normalize(_WorldSpaceCameraPos.xyz-i.posWS);
                half3 vrDirWS=reflect(-vDirWS,nDirWS);
                half3 lDirWS=_WorldSpaceLightPos0.xyz;
                half shadow=LIGHT_ATTENUATION(i);
                //中间量计算
                half3 lrDirWS=reflect(-lDirWS,nDirWS);
                half ndotl=dot(nDirWS,lDirWS);
                half ndotv=dot(nDirWS,vDirWS);
                half vdotr=dot(vDirWS,lrDirWS);
                //纹理采样
                half3 var_BaseCol=tex2D(_BaseCol,i.uv0);
                half var_Alpha=tex2D(_Alpha,i.uv0);
                half var_SpecInt=tex2D(_SpecInt,i.uv0);
                half var_RimInt=tex2D(_RimInt,i.uv0);
                half var_TintMask=tex2D(_TintMask,i.uv0);
                half var_SpecPow=tex2D(_SpecPow,i.uv0);
                half var_NormTex=tex2D(_NormTex,i.uv0);
                half var_MetalnessMask=tex2D(_MetalnessMask,i.uv0);
                half var_EmissionMask=tex2D(_EmissionMask,i.uv0);
                half var_FresnelCol=tex1D(_FresnelCol,ndotv);
                half var_FresnelRim=tex1D(_FresnelRim,ndotv);
                half var_FresnelSpec=tex1D(_FresnelSpec,ndotv);
                half3 var_Cubemap=texCUBElod(_Cubemap,lerp(7.0,0.0,var_SpecPow)).rgb;
                //光照模型
                /*漫反射与镜面反射颜色*/
                half3 diffCol=lerp(var_BaseCol,half3(0.0,0.0,0.0),var_MetalnessMask);
                half3 specCol=lerp(var_BaseCol,half3(0.3,0.3,0.3),var_SpecInt)*var_SpecInt;
                /*菲涅尔*/
                half fresnelCol=lerp(var_FresnelCol,0.0,var_MetalnessMask);
                half fresnelRim=lerp(var_FresnelRim,0.0,var_MetalnessMask);
                half fresnelSpec=lerp(var_FresnelSpec,0.0,var_MetalnessMask);
                /*光源漫反射*/
                half halfLambert=ndotl*0.5+0.5;
                half3 var_DiffuseWarpTex=tex2D(_DiffuseWarpTex,half2(halfLambert,0.2));
                half3 dirDiff=diffCol*var_DiffuseWarpTex*_LightCol;
                /*光源镜面反射*/
                half phong=pow(max(0.0,vdotr),var_SpecPow*_SpecPower);
                half spec=phong*max(0.0,ndotl);
                spec=max(spec,var_FresnelSpec);
                spec=spec*_SpecIntensity;
                half3 dirSpec=specCol*spec*_LightCol;
                /*环境漫反射*/
                half3 envDiff=diffCol*_EnvCol*_EnvDiffInt;
                /*环境镜面反射*/
                half reflectInt=max(fresnelSpec,var_MetalnessMask)*var_SpecInt;
                half3 envSpec=specCol*reflectInt*var_Cubemap*_EnvSpecInt;
                /*轮廓光*/
                half3 rimLight=_RimCol*fresnelRim*var_RimInt*max(0.0,nDirWS.y)*_RimIntensity;
                /*自发光*/
                half3 emission=diffCol*var_EmissionMask*_EmitInt;
                /*透明剪切*/
                clip(var_Alpha-_Cutoff);
                fixed3 finalRGB=(dirDiff+dirSpec)*shadow+envDiff+envSpec+rimLight+emission;
                return fixed4(finalRGB,1.0);
            }
            ENDCG
        }
    }
    FallBack "Legacy Shaders/Transparent/Cutout/VertexLit"
}
