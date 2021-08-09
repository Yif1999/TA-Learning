// Shader created with Shader Forge v1.40 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.40;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,cpap:True,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33332,y:33342,varname:node_3138,prsc:2|emission-9786-RGB,olwid-2516-OUT,olcol-9509-RGB;n:type:ShaderForge.SFN_Dot,id:5453,x:32111,y:32824,varname:node_5453,prsc:2,dt:0|A-7292-OUT,B-819-OUT;n:type:ShaderForge.SFN_NormalVector,id:7292,x:31901,y:32824,prsc:2,pt:False;n:type:ShaderForge.SFN_LightVector,id:819,x:31901,y:32993,varname:node_819,prsc:2;n:type:ShaderForge.SFN_Multiply,id:9007,x:32284,y:32834,varname:node_9007,prsc:2|A-5453-OUT,B-2681-OUT;n:type:ShaderForge.SFN_Vector1,id:2681,x:32102,y:33293,varname:node_2681,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Add,id:3807,x:32514,y:32834,varname:node_3807,prsc:2|A-9007-OUT,B-2681-OUT;n:type:ShaderForge.SFN_Append,id:8354,x:32750,y:33273,varname:node_8354,prsc:2|A-7242-OUT,B-2681-OUT;n:type:ShaderForge.SFN_Tex2d,id:9786,x:33016,y:33273,ptovrint:False,ptlb:node_9786,ptin:_node_9786,varname:node_9786,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:bfbdebd9967764241a5d8131e9939d62,ntxv:0,isnm:False|UVIN-8354-OUT;n:type:ShaderForge.SFN_Multiply,id:3056,x:32725,y:32886,varname:node_3056,prsc:2|A-3807-OUT,B-4888-OUT;n:type:ShaderForge.SFN_Vector1,id:4888,x:32491,y:33029,varname:node_4888,prsc:2,v1:-1;n:type:ShaderForge.SFN_Vector1,id:2187,x:32491,y:33125,varname:node_2187,prsc:2,v1:1;n:type:ShaderForge.SFN_Add,id:7242,x:32912,y:33040,varname:node_7242,prsc:2|A-3056-OUT,B-2187-OUT;n:type:ShaderForge.SFN_Vector1,id:2516,x:33064,y:33596,varname:node_2516,prsc:2,v1:0.01;n:type:ShaderForge.SFN_Color,id:9509,x:32843,y:33625,ptovrint:False,ptlb:node_9509,ptin:_node_9509,varname:node_9509,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.254902,c2:0.1882353,c3:0.1764706,c4:1;proporder:9786-9509;pass:END;sub:END;*/

Shader "Shader Forge/Cartoon" {
    Properties {
        _node_9786 ("node_9786", 2D) = "white" {}
        _node_9509 ("node_9509", Color) = (0.254902,0.1882353,0.1764706,1)
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
                UNITY_DEFINE_INSTANCED_PROP( float4, _node_9509)
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
                float4 _node_9509_var = UNITY_ACCESS_INSTANCED_PROP( Props, _node_9509 );
                return fixed4(_node_9509_var.rgb,0);
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
                LIGHTING_COORDS(2,3)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
////// Lighting:
////// Emissive:
                float node_2681 = 0.5;
                float node_7242 = ((((dot(i.normalDir,lightDirection)*node_2681)+node_2681)*(-1.0))+1.0);
                float2 node_8354 = float2(node_7242,node_2681);
                float4 _node_9786_var = tex2D(_node_9786,TRANSFORM_TEX(node_8354, _node_9786));
                float3 emissive = _node_9786_var.rgb;
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
                LIGHTING_COORDS(2,3)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
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
