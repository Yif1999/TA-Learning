// Shader created with Shader Forge v1.40 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.40;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,cpap:True,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:34370,y:33086,varname:node_3138,prsc:2|emission-5780-OUT,olwid-2704-OUT,olcol-2085-RGB;n:type:ShaderForge.SFN_Dot,id:5453,x:32245,y:33334,varname:node_5453,prsc:2,dt:0|A-7292-OUT,B-819-OUT;n:type:ShaderForge.SFN_NormalVector,id:7292,x:32035,y:33334,prsc:2,pt:False;n:type:ShaderForge.SFN_LightVector,id:819,x:32035,y:33503,varname:node_819,prsc:2;n:type:ShaderForge.SFN_Multiply,id:9007,x:32418,y:33344,varname:node_9007,prsc:2|A-5453-OUT,B-2681-OUT;n:type:ShaderForge.SFN_Vector1,id:2681,x:32334,y:33723,varname:node_2681,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Add,id:3807,x:32626,y:33344,varname:node_3807,prsc:2|A-9007-OUT,B-2681-OUT;n:type:ShaderForge.SFN_Append,id:8354,x:33507,y:33548,varname:node_8354,prsc:2|A-7242-OUT,B-2681-OUT;n:type:ShaderForge.SFN_Tex2d,id:9786,x:33696,y:33497,ptovrint:False,ptlb:node_9786,ptin:_node_9786,varname:_node_9786,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:bfbdebd9967764241a5d8131e9939d62,ntxv:0,isnm:False|UVIN-8354-OUT;n:type:ShaderForge.SFN_Multiply,id:3056,x:33090,y:33424,varname:node_3056,prsc:2|A-3807-OUT,B-4888-OUT;n:type:ShaderForge.SFN_Vector1,id:4888,x:32902,y:33497,varname:node_4888,prsc:2,v1:-1;n:type:ShaderForge.SFN_Vector1,id:2187,x:32991,y:33573,varname:node_2187,prsc:2,v1:1;n:type:ShaderForge.SFN_Add,id:7242,x:33318,y:33442,varname:node_7242,prsc:2|A-3056-OUT,B-2187-OUT;n:type:ShaderForge.SFN_ScreenPos,id:3444,x:32518,y:32730,varname:node_3444,prsc:2,sctp:1;n:type:ShaderForge.SFN_Multiply,id:3908,x:32779,y:32919,varname:node_3908,prsc:2|A-3444-UVOUT,B-6685-OUT;n:type:ShaderForge.SFN_Vector1,id:6685,x:32394,y:33091,varname:node_6685,prsc:2,v1:40;n:type:ShaderForge.SFN_Frac,id:8958,x:32993,y:32982,varname:node_8958,prsc:2|IN-3908-OUT;n:type:ShaderForge.SFN_RemapRange,id:8738,x:33202,y:32982,varname:node_8738,prsc:2,frmn:0,frmx:1,tomn:-0.5,tomx:0.5|IN-8958-OUT;n:type:ShaderForge.SFN_Length,id:8855,x:33437,y:33062,varname:node_8855,prsc:2|IN-8738-OUT;n:type:ShaderForge.SFN_Power,id:4103,x:33657,y:33176,varname:node_4103,prsc:2|VAL-8855-OUT,EXP-6182-OUT;n:type:ShaderForge.SFN_Color,id:2085,x:33898,y:33714,ptovrint:False,ptlb:node_2085,ptin:_node_2085,varname:node_2085,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.2,c2:0.1,c3:0.1,c4:1;n:type:ShaderForge.SFN_Vector1,id:2704,x:33898,y:33597,varname:node_2704,prsc:2,v1:0.01;n:type:ShaderForge.SFN_Multiply,id:1864,x:34064,y:33380,varname:node_1864,prsc:2|A-2893-OUT,B-9786-RGB;n:type:ShaderForge.SFN_RemapRange,id:6182,x:33090,y:33207,varname:node_6182,prsc:2,frmn:0,frmx:1,tomn:1,tomx:-0.5|IN-3807-OUT;n:type:ShaderForge.SFN_Round,id:2893,x:33842,y:33214,varname:node_2893,prsc:2|IN-4103-OUT;n:type:ShaderForge.SFN_Blend,id:5780,x:34122,y:33191,varname:node_5780,prsc:2,blmd:1,clmp:True|SRC-2893-OUT,DST-9786-RGB;proporder:9786-2085;pass:END;sub:END;*/

Shader "Shader Forge/HalfToon" {
    Properties {
        _node_9786 ("node_9786", 2D) = "white" {}
        _node_2085 ("node_2085", Color) = (0.2,0.1,0.1,1)
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "Outline"
            Tags {
            }
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma target 3.0
            UNITY_INSTANCING_BUFFER_START( Props )
                UNITY_DEFINE_INSTANCED_PROP( float4, _node_2085)
            UNITY_INSTANCING_BUFFER_END( Props )
            struct VertexInput {
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID( v );
                UNITY_TRANSFER_INSTANCE_ID( v, o );
                o.pos = UnityObjectToClipPos( float4(v.vertex.xyz + v.normal*0.01,1) );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                UNITY_SETUP_INSTANCE_ID( i );
                float4 _node_2085_var = UNITY_ACCESS_INSTANCED_PROP( Props, _node_2085 );
                return fixed4(_node_2085_var.rgb,0);
            }
            ENDCG
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            uniform sampler2D _node_9786; uniform float4 _node_9786_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                float4 projPos : TEXCOORD2;
                LIGHTING_COORDS(3,4)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                float2 sceneUVs = (i.projPos.xy / i.projPos.w);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
////// Lighting:
////// Emissive:
                float node_2681 = 0.5;
                float node_3807 = ((dot(i.normalDir,lightDirection)*node_2681)+node_2681);
                float node_2893 = round(pow(length((frac((float2((sceneUVs.x * 2 - 1)*(_ScreenParams.r/_ScreenParams.g), sceneUVs.y * 2 - 1).rg*40.0))*1.0+-0.5)),(node_3807*-1.5+1.0)));
                float2 node_8354 = float2(((node_3807*(-1.0))+1.0),node_2681);
                float4 _node_9786_var = tex2D(_node_9786,TRANSFORM_TEX(node_8354, _node_9786));
                float3 emissive = saturate((node_2893*_node_9786_var.rgb));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma target 3.0
            uniform sampler2D _node_9786; uniform float4 _node_9786_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                float4 projPos : TEXCOORD2;
                LIGHTING_COORDS(3,4)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                float2 sceneUVs = (i.projPos.xy / i.projPos.w);
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
////// Lighting:
                float3 finalColor = 0;
                return fixed4(finalColor * 1,0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
