// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ToonDissolv"
{
	Properties
	{
		_Tint("Tint", Color) = (1,1,1,0)
		_AlbedoTexture("AlbedoTexture", 2D) = "white" {}
		_NormalTexture("NormalTexture", 2D) = "bump" {}
		[HDR]_Emission("Emission", Color) = (0,0,0,0)
		_Emissionmap("Emission map", 2D) = "white" {}
		_RimTint("Rim Tint", Color) = (0,1,0.7995415,0)
		_RimPower("Rim Power", Range( 0 , 1)) = 0.001
		_Rimoffset("Rim offset", Float) = 1
		_Gloss("Gloss", Range( 0 , 1)) = 0
		_Specintensity("Spec intensity", Range( 0 , 1)) = 0
		_Specularmap("Specular map", 2D) = "white" {}
		_Specblend("Spec blend", Range( 0 , 1)) = 0.5
		_Speccolor("Spec color", Color) = (1,1,1,0)
		_ToonRamp("Toon Ramp", 2D) = "white" {}
		_ShadowForward("Shadow Forward", Range( 0 , 1)) = 0.4697093
		_Distance("Distance", Float) = 5
		_Opacitystepmin("Opacity step min", Range( 0 , 1)) = 0
		_Opacitystepmax("Opacity step max", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		AlphaToMask On
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _Emissionmap;
		uniform float4 _Emissionmap_ST;
		uniform float4 _Emission;
		uniform float _Opacitystepmin;
		uniform float _Opacitystepmax;
		uniform float _Distance;
		uniform float3 PlayerPosition;
		uniform float _Rimoffset;
		uniform sampler2D _NormalTexture;
		uniform float4 _NormalTexture_ST;
		uniform float _RimPower;
		uniform float4 _RimTint;
		uniform float4 _Tint;
		uniform sampler2D _AlbedoTexture;
		uniform float4 _AlbedoTexture_ST;
		uniform sampler2D _ToonRamp;
		uniform float _ShadowForward;
		uniform float _Gloss;
		uniform sampler2D _Specularmap;
		uniform float4 _Specularmap_ST;
		uniform float4 _Speccolor;
		uniform float _Specblend;
		uniform float _Specintensity;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float3 ase_worldPos = i.worldPos;
			float temp_output_314_0 = distance( ase_worldPos , PlayerPosition );
			float clampResult330 = clamp( ( _Distance / temp_output_314_0 ) , 0.0 , 1.0 );
			float smoothstepResult331 = smoothstep( _Opacitystepmin , _Opacitystepmax , clampResult330);
			float2 uv_NormalTexture = i.uv_texcoord * _NormalTexture_ST.xy + _NormalTexture_ST.zw;
			float3 Normal71 = UnpackNormal( tex2D( _NormalTexture, uv_NormalTexture ) );
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult15 = dot( normalize( (WorldNormalVector( i , Normal71 )) ) , ase_worldViewDir );
			float normal_ViewDir25 = dotResult15;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult13 = dot( normalize( (WorldNormalVector( i , Normal71 )) ) , ase_worldlightDir );
			float normal_LightDir24 = dotResult13;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 rim267 = ( saturate( ( pow( ( 1.0 - saturate( ( _Rimoffset + normal_ViewDir25 ) ) ) , _RimPower ) * ( normal_LightDir24 * ase_lightAtten ) ) ) * ( ase_lightColor * _RimTint ) );
			float2 uv_AlbedoTexture = i.uv_texcoord * _AlbedoTexture_ST.xy + _AlbedoTexture_ST.zw;
			float4 Albedo80 = ( _Tint * tex2D( _AlbedoTexture, uv_AlbedoTexture ) );
			float2 temp_cast_1 = ((normal_LightDir24*_ShadowForward + _ShadowForward)).xx;
			float4 shadow31 = ( Albedo80 * tex2D( _ToonRamp, temp_cast_1 ) );
			UnityGI gi252 = gi;
			float3 diffNorm252 = WorldNormalVector( i , Normal71 );
			gi252 = UnityGI_Base( data, 1, diffNorm252 );
			float3 indirectDiffuse252 = gi252.indirect.diffuse + diffNorm252 * 0.0001;
			float4 lighting242 = ( shadow31 * ( ase_lightColor * float4( ( indirectDiffuse252 + ase_lightAtten ) , 0.0 ) ) );
			float dotResult287 = dot( ( ase_worldViewDir + _WorldSpaceLightPos0.xyz ) , normalize( (WorldNormalVector( i , Normal71 )) ) );
			float smoothstepResult300 = smoothstep( 1.1 , 1.12 , pow( dotResult287 , _Gloss ));
			float2 uv_Specularmap = i.uv_texcoord * _Specularmap_ST.xy + _Specularmap_ST.zw;
			float4 lerpResult306 = lerp( _Speccolor , ase_lightColor , _Specblend);
			float4 Spec297 = ( ( ( smoothstepResult300 * ( tex2D( _Specularmap, uv_Specularmap ) * lerpResult306 ) ) * _Specintensity ) * ase_lightAtten );
			c.rgb = ( rim267 + lighting242 + Spec297 ).rgb;
			c.a = smoothstepResult331;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float2 uv_Emissionmap = i.uv_texcoord * _Emissionmap_ST.xy + _Emissionmap_ST.zw;
			o.Emission = ( tex2D( _Emissionmap, uv_Emissionmap ) * _Emission ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
0;4;1920;1055;118.8929;-1249.872;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;72;-1486.627,-646.9694;Inherit;False;660.9767;280.7395;Comment;2;71;311;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;311;-1461.299,-573.6254;Inherit;True;Property;_NormalTexture;NormalTexture;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-1049.65,-596.9694;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;26;-1182.488,-123.462;Inherit;False;699.5618;441.811;ViewDir;4;16;15;14;25;ViewDir;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-1387.031,-77.74787;Inherit;False;71;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-3050.499,-676.9296;Inherit;False;71;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;27;-2893.877,-721.1312;Inherit;False;964.2003;492.2;Normall ligtht;4;11;12;13;24;Normal lightdir;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;14;-1132.488,-73.46201;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;16;-1116.974,130.3491;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;15;-917.797,24.18213;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;12;-2843.877,-411.9312;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;11;-2809.095,-682.591;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;309;-4040.445,1671.933;Inherit;False;2980.784;1343.452;Comment;23;286;282;283;284;285;289;287;304;307;305;290;288;291;306;302;300;308;301;294;296;293;295;297;Specularity;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;281;-4062.372,746.4845;Inherit;False;2565.127;806.209;Comment;17;269;260;262;263;276;266;264;274;275;265;271;277;270;272;278;273;267;Rim;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;81;-1513.355,-1228.523;Inherit;False;788.6118;470.5653;Comment;4;78;79;80;310;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;13;-2503.336,-524.8536;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-710.9266,24.48358;Inherit;True;normal_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-2202.756,-527.6464;Inherit;True;normal_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;310;-1477.508,-976.0304;Inherit;True;Property;_AlbedoTexture;AlbedoTexture;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightPos;283;-3990.445,1915.161;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;69;-3222.863,-177.0645;Inherit;False;1720.927;831.8987;Comment;7;30;29;31;44;45;82;84;Shadow;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;269;-3951.152,796.4845;Inherit;False;Property;_Rimoffset;Rim offset;8;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;78;-1440.144,-1178.523;Inherit;False;Property;_Tint;Tint;1;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;282;-3939.251,1721.933;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;260;-4012.372,886.7825;Inherit;False;25;normal_ViewDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;286;-3940.445,2039.161;Inherit;False;71;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-3040.863,32.04428;Inherit;False;24;normal_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;285;-3702.445,2046.161;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-1125.744,-1057.524;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;284;-3648.445,1833.162;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;262;-3721.229,840.8976;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-3065.731,281.8342;Inherit;False;Property;_ShadowForward;Shadow Forward;15;0;Create;True;0;0;False;0;0.4697093;0.562;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;305;-2913.681,2758.385;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;263;-3419.965,847.9875;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;257;-1356.235,596.8795;Inherit;False;1241.462;521.6953;Comment;9;255;253;252;250;254;256;249;251;242;Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;289;-3445.445,2088.162;Inherit;True;Property;_Gloss;Gloss;9;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;307;-3014.681,2899.385;Inherit;False;Property;_Specblend;Spec blend;12;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;44;-2705.731,190.8341;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-948.7436,-1066.523;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;304;-2965.681,2562.385;Inherit;False;Property;_Speccolor;Spec color;13;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;287;-3404.445,1900.162;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;302;-3025.17,2322.289;Inherit;True;Property;_Specularmap;Specular map;11;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;266;-3159.465,1064.187;Inherit;False;Property;_RimPower;Rim Power;7;0;Create;True;0;0;False;0;0.001;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;306;-2636.681,2663.385;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;290;-2981.446,2079.162;Inherit;False;Constant;_Min;Min;11;0;Create;True;0;0;False;0;1.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;30;-2443.631,106.2663;Inherit;True;Property;_ToonRamp;Toon Ramp;14;0;Create;True;0;0;False;0;-1;b1fe6cd68b0c49c41a5974d465c8970c;52e66a9243cdfed44b5e906f5910d35b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;288;-3119.445,1965.161;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;255;-1306.235,896.5748;Inherit;False;71;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;82;-2336.137,-105.488;Inherit;True;80;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;291;-3001.446,2232.162;Inherit;False;Constant;_Max;Max;12;0;Create;True;0;0;False;0;1.12;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;264;-3084.965,889.9875;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;276;-3122.305,1441.692;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;274;-3142.948,1314.897;Inherit;False;24;normal_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;300;-2775.588,1996.707;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-2007.137,26.51196;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;252;-1082.235,902.5748;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;308;-2421.632,2538.697;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;253;-1228.235,1001.575;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;275;-2855.969,1364.208;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;265;-2774.965,942.9874;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;277;-2505.501,1003.566;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;254;-828.2354,941.5748;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;294;-2212.106,2262.554;Inherit;False;Property;_Specintensity;Spec intensity;10;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;250;-1010.625,701.1157;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;271;-2304.267,1334.091;Inherit;False;Property;_RimTint;Rim Tint;6;0;Create;True;0;0;False;0;0,1,0.7995415,0;0,1,0.7995415,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-1764.935,91.75091;Inherit;False;shadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;270;-2247.267,1169.092;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;301;-2404.17,2004.288;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;296;-1814.061,2328.131;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;-1813.105,2060.554;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;249;-722.6246,670.1157;Inherit;False;31;shadow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;272;-2081.948,1223.978;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;278;-2240.043,996.2012;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;329;-689.9091,1581.493;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;315;-698.0143,1745.129;Inherit;False;Global;PlayerPosition;PlayerPosition;15;0;Create;True;0;0;False;0;0,0,0;4.39,0.43,13.399;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;256;-671.2354,836.5748;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;324;64.03802,1619.172;Inherit;False;Property;_Distance;Distance;16;0;Create;True;0;0;False;0;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;-1497.574,2184.101;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceOpNode;314;-338.0768,1685.041;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;251;-512.6246,685.1157;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;273;-1935.348,979.7773;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;297;-1283.661,2206.332;Inherit;False;Spec;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;242;-338.773,646.8795;Inherit;False;lighting;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;267;-1721.245,962.6984;Inherit;True;rim;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;323;257.1691,1705.343;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;330;426.4328,1585.854;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;220;129.4357,493.3054;Inherit;True;Property;_Emissionmap;Emission map;5;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;218;164.9233,721.3054;Inherit;False;Property;_Emission;Emission;4;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;268;188.7038,1189.613;Inherit;False;267;rim;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;245;181.0157,1300.219;Inherit;False;242;lighting;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;332;790.4199,1785.747;Inherit;False;Property;_Opacitystepmin;Opacity step min;17;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;298;166.1547,1445.32;Inherit;False;297;Spec;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;333;796.4199,1926.747;Inherit;False;Property;_Opacitystepmax;Opacity step max;18;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;331;1117.42,1662.747;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;334;1365.153,1712.354;Inherit;False;opacitytity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;327;-151.6102,1612.443;Inherit;False;playerDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;491.5043,757.0524;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;279;597.7442,1259.58;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;241;1500.898,1057.594;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;ToonDissolv;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;1;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;71;0;311;0
WireConnection;14;0;74;0
WireConnection;15;0;14;0
WireConnection;15;1;16;0
WireConnection;11;0;73;0
WireConnection;13;0;11;0
WireConnection;13;1;12;0
WireConnection;25;0;15;0
WireConnection;24;0;13;0
WireConnection;285;0;286;0
WireConnection;79;0;78;0
WireConnection;79;1;310;0
WireConnection;284;0;282;0
WireConnection;284;1;283;1
WireConnection;262;0;269;0
WireConnection;262;1;260;0
WireConnection;263;0;262;0
WireConnection;44;0;29;0
WireConnection;44;1;45;0
WireConnection;44;2;45;0
WireConnection;80;0;79;0
WireConnection;287;0;284;0
WireConnection;287;1;285;0
WireConnection;306;0;304;0
WireConnection;306;1;305;0
WireConnection;306;2;307;0
WireConnection;30;1;44;0
WireConnection;288;0;287;0
WireConnection;288;1;289;0
WireConnection;264;0;263;0
WireConnection;300;0;288;0
WireConnection;300;1;290;0
WireConnection;300;2;291;0
WireConnection;84;0;82;0
WireConnection;84;1;30;0
WireConnection;252;0;255;0
WireConnection;308;0;302;0
WireConnection;308;1;306;0
WireConnection;275;0;274;0
WireConnection;275;1;276;0
WireConnection;265;0;264;0
WireConnection;265;1;266;0
WireConnection;277;0;265;0
WireConnection;277;1;275;0
WireConnection;254;0;252;0
WireConnection;254;1;253;0
WireConnection;31;0;84;0
WireConnection;301;0;300;0
WireConnection;301;1;308;0
WireConnection;293;0;301;0
WireConnection;293;1;294;0
WireConnection;272;0;270;0
WireConnection;272;1;271;0
WireConnection;278;0;277;0
WireConnection;256;0;250;0
WireConnection;256;1;254;0
WireConnection;295;0;293;0
WireConnection;295;1;296;0
WireConnection;314;0;329;0
WireConnection;314;1;315;0
WireConnection;251;0;249;0
WireConnection;251;1;256;0
WireConnection;273;0;278;0
WireConnection;273;1;272;0
WireConnection;297;0;295;0
WireConnection;242;0;251;0
WireConnection;267;0;273;0
WireConnection;323;0;324;0
WireConnection;323;1;314;0
WireConnection;330;0;323;0
WireConnection;331;0;330;0
WireConnection;331;1;332;0
WireConnection;331;2;333;0
WireConnection;334;0;331;0
WireConnection;327;0;314;0
WireConnection;219;0;220;0
WireConnection;219;1;218;0
WireConnection;279;0;268;0
WireConnection;279;1;245;0
WireConnection;279;2;298;0
WireConnection;241;2;219;0
WireConnection;241;9;331;0
WireConnection;241;13;279;0
ASEEND*/
//CHKSM=04B8C21F8CA82C619325E46E3EE0EC9DDE2AD002