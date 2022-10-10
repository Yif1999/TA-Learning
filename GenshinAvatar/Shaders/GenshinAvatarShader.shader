Shader "Yif/GenshinAvatarShader"
{
    Properties
    {
        [Header(Feature)]
        [Space(15)]
        [KeywordEnum(Body,Face)]_RENDER("Body Parts",float)=0 
        [Header(Texture)]
        [Space(15)]
        _BaseMap("BaseMap", 2D) = "white" {}
        [NoScaleOffset]_LightMap("LightMap",2D) = "white" {}
        [NoScaleOffset]_MetalMap("MetalMap",2D) = "white" {}
        [NoScaleOffset]_RampMap("RampMap",2D) = "white" {}
        [NoScaleOffset]_AdditionalMap("AdditionalMap",2D) = "white" {}
        [Header(Parameter)]
        [Space(15)]
        [Enum(Day,2,Night,1)]_TimeShift("Day&Night Switch",int) = 2
        [Space(10)]
        _BoundaryIntensity("Boundary Intensity",range(0.0,1.0))=0.1
        [Space(10)]
        _ShadowOffset("Shadow Offset",range(0.0,1.0))=0
        _ShadowRampWidth("Shadow Ramp Width",range(0.0,1.0))=0.1
        _ShadowRampThreshold("Shadow Ramp Threshold",range(0.0,1.0))=0.0
        [Space(10)]
        _BPSpecularIntensity("Blin-Phong Specular Intensity",range(0.0,10.0))=0.5
        [PowerSlider(2)]_SpecularExp("Specular Exponent",range(1.0,128.0))=0.5
        _ViewSpecularWidth("View Specular Width",range(0.0,1.0))=0.5
        _NonmetalSpecularIntensity("Nonmetal Specular Intensity",range(0.0,10.0))=0.5
        _MetalSpecularIntensity("Metal Specular Intensity",range(0.0,10.0))=0.5
        [Space(10)]
        _EmissionIntensity("Emission Intensity",range(0.0,10.0))=1.0
        [Space(10)]
        _RimLightWidth("Rim Light Width",range(0.0,0.01))=0.006
        _RimLightThreshold("Rim Light Threshold",range(0.0,1))=0.6
        _RimLightIntensity("Rim Light Intensity",range(0.0,1))=0.25
        [Space(10)]
        _OutlineColor("Outline Color",color)=(0.0,0.0,0.0)
        _OutlineWidth("Outline Width",range(0.0,0.01))=0.01
        [HideInInspector]
        _fDirWS("Face Front Direction",vector)=(0,0,1,0)
    }
 
    SubShader
    {
        LOD 100
        Tags 
        { 
            "Queue"="Geometry" 
            "RenderType" = "Opaque" 
            "IgnoreProjector" = "True" 
            "RenderPipeline" = "UniversalPipeline"
        }
        HLSLINCLUDE
        #pragma vertex vert
        #pragma fragment frag
        #pragma shader_feature _RENDER_BODY _RENDER_FACE
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"

        //URP中变量需在改框架下声明以持久化内存
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_ST;
        float4 _LightMap_ST;
        float4 _MetalMap_ST;
        float4 _RampMap_ST;
        float4 _AdditionalMap_ST;
        float _BoundaryIntensity;
        float _ShadowOffset;
        float _ShadowRampWidth;
        float _ShadowRampThreshold;
        float _ViewSpecularWidth;
        float _NonmetalSpecularIntensity;
        float _MetalSpecularIntensity;
        float _SpecularExp;
        float _BPSpecularIntensity;
        float _EmissionIntensity;
        float _RimLightWidth;
        float _RimLightThreshold;
        float _RimLightIntensity;
        float _OutlineWidth;
        half4 _OutlineColor;
        float3 _fDirWS;
        int _TimeShift;
        CBUFFER_END

        //纹理与采样器类型使用URP宏另外声明
        TEXTURE2D (_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D (_LightMap);
        SAMPLER(sampler_LightMap);
        TEXTURE2D (_MetalMap);
        SAMPLER(sampler_MetalMap);
        TEXTURE2D (_RampMap);
        SAMPLER(sampler_RampMap);
        TEXTURE2D (_AdditionalMap);
        SAMPLER(sampler_AdditionalMap);
        TEXTURE2D_X_FLOAT(_CameraDepthTexture); 
        SAMPLER(sampler_CameraDepthTexture);
        
        //应用阶段结构体声明
        struct Attributes
        {
            float4 posOS            : POSITION;
            float2 uv               : TEXCOORD0;
            float3 normalOS         : NORMAL;
            float4 tangentOS        : TANGENT;
            float4 vertexColor      : COLOR;
        };

        //几何阶段结构体声明
        struct Varyings
        {
            float4 posCS            : SV_POSITION;
            float2 uv               : TEXCOORD0;
            float3 posWS            : TEXCOORD1;
            float3 nDirWS           : TEXCOORD2;
            float4 col              : COLOR;
        };

        //自定义工具函数Ramp
        float remap(float x,float t1,float t2,float s1,float s2)
        {
            return (x-t1) / (t2-t1) * (s2-s1) + s1;
        }
        ENDHLSL
 
        Pass
        {
            Cull Off

            Name "Forward"
            Tags{ "LightMode" = "UniversalForward" } 
            HLSLPROGRAM

            //顶点着色器
            Varyings vert(Attributes v)
            {
                Varyings o;
 
                o.posCS = TransformObjectToHClip(v.posOS.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.posWS = TransformObjectToWorld(v.posOS);
                o.nDirWS=TransformObjectToWorldNormal(v.normalOS);
                o.col=v.vertexColor;

                return o;
            }

            //片段着色器
            half4 frag(Varyings i) : SV_Target
            {
#if _RENDER_BODY
                //光源信息
                Light mainLight = GetMainLight(); 
                float4 mainLightColor = float4(mainLight.color, 1); 

                //方向信息
                float3 lDirWS = normalize(mainLight.direction);
                float3 vDirWS = normalize(GetCameraPositionWS()-i.posWS);
                float3 nDirVS = TransformWorldToView(i.nDirWS);
                float ndotl = dot(i.nDirWS, lDirWS);
                float ndoth = dot(i.nDirWS, normalize(vDirWS + lDirWS));
                float ndotv = dot(i.nDirWS, vDirWS);
                float ldotv = dot(lDirWS, vDirWS);
                
                //纹理采样
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                float4 lightMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, i.uv); 

                //通道拆分
                float AOMask = saturate(lightMap.g*2.0);
                float shadowMask = step(0.8,lightMap.g);
                float MatID = lightMap.a*0.45;
                float nonmetalSpecMask = saturate(sign(0.45-abs(0.45-lightMap.r)));
                float metalSpecMask = step(0.8,lightMap.r);
                float specularIntensity = lightMap.b;
                float emissionMask=step(0.5,baseMap.a);

                //光照计算
                float lambert= clamp(ndotl + AOMask - 1, -1, 1);
                float lambertRemap = smoothstep(-_ShadowOffset, -_ShadowOffset+_ShadowRampWidth, lambert);
                float halfLambert= lambert *0.5 +0.5;
                float rampSampler = remap(halfLambert,0,1,_ShadowRampThreshold,1);
                float2 rampUV=float2(clamp(rampSampler,0.1,0.9),MatID+(_TimeShift-1.0)*0.5-0.1);
                half4 rampShadow = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, rampUV);

                half4 shadowLayer = step(0.1,lambert)+lerp(rampShadow,max(mainLightColor,rampShadow),1-_BoundaryIntensity) * baseMap;
                half4 litLayer = lerp(rampShadow, max(mainLightColor,rampShadow), lambertRemap) * baseMap;
                half4 diffuse = lerp(min(shadowLayer,litLayer),baseMap,shadowMask);

                float nonmetalSpec=step(1 - _ViewSpecularWidth, saturate(ndotv)*step(0,lambert)) *_NonmetalSpecularIntensity * nonmetalSpecMask * specularIntensity;
                nonmetalSpec += pow(saturate(ndoth),_SpecularExp) *nonmetalSpecMask *specularIntensity * _BPSpecularIntensity;
                float metalMap = SAMPLE_TEXTURE2D(_MetalMap, sampler_MetalMap, vDirWS.xy * 0.5 + 0.5).r;
                float metalSpec = metalMap * _MetalSpecularIntensity * metalSpecMask * specularIntensity;
                half4 specular = lerp(nonmetalSpec,metalSpec*baseMap,specularIntensity);

                half4 emission = _EmissionIntensity*baseMap*emissionMask;

                float2 scrUV = float2(i.posCS.x / _ScreenParams.x, i.posCS.y / _ScreenParams.y);
                float2 offsetPos = scrUV + float2(nDirVS.xy *_RimLightWidth* clamp(-ldotv,0.5,1) / i.posCS.w);
                float offsetDepth = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture ,offsetPos),_ZBufferParams);
                float originalDepth = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, scrUV),_ZBufferParams);
                float rimMask = step(0.25,smoothstep(0,_RimLightThreshold,offsetDepth-originalDepth));
                half4 rimLight = rimMask * baseMap *_RimLightIntensity;

                half4 color=diffuse+specular+emission+rimLight;

#elif _RENDER_FACE
                //光源信息
                Light mainLight = GetMainLight(); 
                float4 mainLightColor = float4(mainLight.color, 1); 

                //方向信息
                float3 uDirWS = float3(0,1,0);
                float3 fDirWS = _fDirWS;
                float3 rDirWS = cross(uDirWS,fDirWS);
                float3 lDirWS = normalize(mainLight.direction);
                
                //纹理采样
                half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                float4 lightMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, i.uv); 

                //光照计算
                float2 lDir = normalize(lDirWS.xz);
                float rdotl = dot(normalize(rDirWS.xz),lDir);
                float fdotl = dot(normalize(fDirWS.xz),lDir);
                float faceShadowR=SAMPLE_TEXTURE2D(_LightMap,sampler_LightMap,float2(-i.uv.x,i.uv.y)).a;
                float faceShadowL=SAMPLE_TEXTURE2D(_LightMap,sampler_LightMap,i.uv).a;

                float shadowMap = faceShadowL*step(0,-rdotl)+faceShadowR*step(0,rdotl);
                float inShadow = step(0,shadowMap-(1-fdotl)/2);

                float2 rampUV=float2(clamp(inShadow,0.1,0.9),0.35+(_TimeShift-1.0)*0.5);
                half4 shadowColor = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, rampUV);
                half4 color=lerp(shadowColor, max(mainLightColor,shadowColor), inShadow) * baseMap;
#endif

                return color;
            }
            ENDHLSL
        }

        Pass
        {
            Cull Front

            Name "Outline"
            Tags{ "LightMode" = "SRPDefaultUnlit" }
            HLSLPROGRAM

            Varyings vert(Attributes v)
            {
                Varyings o;

                float outlineWidthMap=_AdditionalMap.SampleLevel(sampler_AdditionalMap,v.uv,0);
                v.posOS.xyz += v.tangentOS.xyz *_OutlineWidth*outlineWidthMap;
                o.uv = v.uv;
                o.posCS= TransformObjectToHClip(v.posOS.xyz);

                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                half4 OutColor = _OutlineColor;

                return OutColor;
            }
            ENDHLSL
        }
    }
}

