Shader "Yif/SSAO"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    CGINCLUDE

    #include "UnityCG.cginc"
    #include "AutoLight.cginc"
    #include "Lighting.cginc"
    #define MAX_SAMPLE_KERNEL_COUNT 64

    struct appdata
    {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float2 uv : TEXCOORD0;
        float2 uvLM : TEXCOORD1;
    };

    struct v2f
    {
        float4 pos : SV_POSITION;
        float4 posWS : TEXCOORD4;
        float3 vecVS : TEXCOORD8;
        float4 posSCR : TEXCOORD7;
        float2 uv : TEXCOORD0;
        float3 nDirWS : NORMAL;
        fixed3 SHLighting : COLOR;
        #ifdef LIGHTMAP_ON
        float2 uvLM : TEXCOORD1;
        #endif
        LIGHTING_COORDS(2,3)
    };

    sampler2D _MainTex;
    float4 _MainTex_ST;

    v2f vert (appdata v)
    {
        v2f o;
        // 基本数据准备
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        o.posSCR=ComputeScreenPos(o.pos);
        o.posWS=mul(unity_ObjectToWorld,v.vertex);
        o.nDirWS=UnityObjectToWorldNormal(v.normal);
        // 引入球谐函数以支持LightProbes
        o.SHLighting= ShadeSH9(float4(o.nDirWS,1)) ;
        TRANSFER_VERTEX_TO_FRAGMENT(o)
        // 计算烘焙间接光UV
        #ifdef LIGHTMAP_ON
        o.uvLM=v.uvLM.xy* unity_LightmapST.xy + unity_LightmapST.zw;
        #endif
        // SSAO
        float4 posNDC=(o.posSCR/o.posSCR.w)*2-1;
        float3 vecCS=float3(posNDC.x,posNDC.y,1.0)*_ProjectionParams.z;
        o.vecVS=mul(unity_CameraInvProjection,vecCS.xyzz).xyz;
        return o;
    }

    sampler2D _CameraDepthNormalsTexture;
    sampler2D _NoiseTex;
    float4 _SampleKernelArray[MAX_SAMPLE_KERNEL_COUNT];
    float _SampleKernelCount;
    float _SampleKernelRadius;
    float _DepthBiasValue;
    float _RangeStrength;
    float _AOStrength;

    fixed4 frag_ao (v2f i) : SV_Target
    {
        // 数据准备
        float2 uvSCR=i.posSCR.xy/i.posSCR.w;
        float3 nDirVS;
        float depth;    
        float4 depthNormalsMap=tex2D(_CameraDepthNormalsTexture,uvSCR);
        DecodeDepthNormal(depthNormalsMap,depth,nDirVS);
        float3 posVS=depth*i.vecVS;
        nDirVS=normalize(nDirVS)*float3(1,1,-1);
        float2 noiseScale=_ScreenParams.xy/4.0;
        float2 noiseUV=uvSCR*noiseScale;
        float3 randCoord=tex2D(_NoiseTex,noiseUV).xyz;
        float3 tangent=normalize(randCoord-nDirVS*dot(randCoord,nDirVS));
        float3 bitangent=cross(nDirVS,tangent);
        float3x3 TBN=float3x3(tangent,bitangent,nDirVS);

        // AO采样
        float ao=0.0;
        int sampleCount=_SampleKernelCount;

        for (int i=0;i<sampleCount;i++){
            float3 randVec=mul(_SampleKernelArray[i].xyz,TBN);
            float weight=smoothstep(0.0,0.2,length(randVec.xy));
            float3 randPosVS=posVS+randVec*_SampleKernelRadius;
            float3 randPosCS=mul((float3x3)unity_CameraProjection,randPosVS);
            float2 randPosSS=(randPosCS.xy/randPosCS.z)*0.5+0.5;
            float randDepth;
            float3 randNDirVS;
            float4 randDepthNormalsMap=tex2D(_CameraDepthNormalsTexture,randPosSS);
            DecodeDepthNormal(randDepthNormalsMap,randDepth,randNDirVS);
            float range=abs(randDepth-depth)>_RangeStrength ? 0.0 : 1.0;
            float selfCheck= randDepth+_DepthBiasValue < depth ? 1.0 : 0.0;
            ao+=range * selfCheck * weight;
        }
        ao=ao/sampleCount;
        ao=max(0.0, 1 - ao * _AOStrength);

        return fixed4(ao,ao,ao,1);
    }

	float _BilaterFilterFactor;
	float2 _MainTex_TexelSize;
	float2 _BlurRadius;

	float3 GetNormal(float2 uv)
	{
		float4 cdn = tex2D(_CameraDepthNormalsTexture, uv);	
		return DecodeViewNormalStereo(cdn);
	}

	half CompareNormal(float3 nor1,float3 nor2)
	{
		return smoothstep(_BilaterFilterFactor,1.0,dot(nor1,nor2));
	}

    fixed4 frag_blur (v2f i) : SV_Target
    {
		float2 delta = _MainTex_TexelSize.xy * _BlurRadius.xy;
		
		float2 uv = i.uv;
		float2 uv0a = i.uv - delta;
		float2 uv0b = i.uv + delta;	
		float2 uv1a = i.uv - 2.0 * delta;
		float2 uv1b = i.uv + 2.0 * delta;
		float2 uv2a = i.uv - 3.0 * delta;
		float2 uv2b = i.uv + 3.0 * delta;
		
		float3 normal = GetNormal(uv);
		float3 normal0a = GetNormal(uv0a);
		float3 normal0b = GetNormal(uv0b);
		float3 normal1a = GetNormal(uv1a);
		float3 normal1b = GetNormal(uv1b);
		float3 normal2a = GetNormal(uv2a);
		float3 normal2b = GetNormal(uv2b);
		
		fixed4 col = tex2D(_MainTex, uv);
		fixed4 col0a = tex2D(_MainTex, uv0a);
		fixed4 col0b = tex2D(_MainTex, uv0b);
		fixed4 col1a = tex2D(_MainTex, uv1a);
		fixed4 col1b = tex2D(_MainTex, uv1b);
		fixed4 col2a = tex2D(_MainTex, uv2a);
		fixed4 col2b = tex2D(_MainTex, uv2b);
		
		half w = 0.37004405286;
		half w0a = CompareNormal(normal, normal0a) * 0.31718061674;
		half w0b = CompareNormal(normal, normal0b) * 0.31718061674;
		half w1a = CompareNormal(normal, normal1a) * 0.19823788546;
		half w1b = CompareNormal(normal, normal1b) * 0.19823788546;
		half w2a = CompareNormal(normal, normal2a) * 0.11453744493;
		half w2b = CompareNormal(normal, normal2b) * 0.11453744493;
		
		half3 result;
		result = w * col.rgb;
		result += w0a * col0a.rgb;
		result += w0b * col0b.rgb;
		result += w1a * col1a.rgb;
		result += w1b * col1b.rgb;
		result += w2a * col2a.rgb;
		result += w2b * col2b.rgb;
		
		result /= w + w0a + w0b + w1a + w1b + w2a + w2b;
		return fixed4(result, 1.0);
    }

    sampler2D _AOTex;

    fixed4 frag_fusion (v2f i) : SV_Target
    {
        // 基本光照模型准备
        float2 uvSCR=i.posSCR.xy/i.posSCR.w;
        half3 nDirWS=normalize(i.nDirWS);
        half3 lDirWS=_WorldSpaceLightPos0.xyz;
        half ndotl=dot(nDirWS,lDirWS);
        half directShadow=LIGHT_ATTENUATION(i);
        half lambert=ndotl*0.5+0.5;
        fixed4 col = tex2D(_MainTex, i.uv)*lambert;

        // 混合烘焙阴影与实时阴影
        // #ifdef LIGHTMAP_ON
        // float viewZ=dot(_WorldSpaceCameraPos-i.posWS,UNITY_MATRIX_V[2].xyz);
        // float shadowFadeDistance=UnityComputeShadowFadeDistance(i.posWS,viewZ);
        // float shadowFade=UnityComputeShadowFade(shadowFadeDistance);
        // float bakedShadow=UnitySampleBakedOcclusion(i.uvLM,i.posWS);
        // float mixShadow=UnityMixRealtimeAndBakedShadows(directShadow,bakedShadow,shadowFade);
        // #else
        // float mixShadow=1.0;
        col*=directShadow;

        // 混合全局光照
        #ifdef LIGHTMAP_ON
        fixed3 lm=DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap,i.uvLM));
        #else
        fixed3 lm=i.SHLighting;
        #endif
        col.rgb+=lm;

        // 混合AO贴图
        fixed4 ao=tex2D(_AOTex,uvSCR)*3;
        col.rgb*=ao.r;

        return fixed4(col.rgb,1);
    }

    ENDCG

    SubShader
    {   
        // 需要从相机获取深度法线缓存必须设定RenderType
        Tags {"RenderType"="Opaque"}

        // Pass0 : Generate AO 
		Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_ao
            ENDCG
        }

		//Pass1 : Bilateral Filter Blur
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_blur
			ENDCG
		}

        // Pass2 : Add AO Effect to Lightmap
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_fusion
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON SHADOWS_SHADOWMASK
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0     
            ENDCG
        }
    }
    FallBack "Diffuse"
}