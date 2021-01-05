// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water"
{
	Properties
	{
		_PrimaryNoiseScale("Primary Noise Scale", Float) = 1
		_SecondaryNoiseScale("Secondary Noise Scale", Float) = 1
		_PrimaryNoiseScroll("Primary Noise Scroll", Vector) = (0,0,0,0)
		_SecondaryNoiseScroll("Secondary Noise Scroll", Vector) = (0,0,0,0)
		_PrimaryNoiseAngle("Primary Noise Angle", Float) = 0
		_SecondaryNoiseAngle("Secondary Noise Angle", Float) = 0
		_CutoffMin("Cutoff Min", Range( 0 , 1)) = 0
		_Tesselation("Tesselation", Float) = 10
		_CutoffMax("Cutoff Max", Range( 0 , 1)) = 1
		[HDR]_WaterColor("WaterColor", Color) = (0,1,0.8411126,0)
		[HDR]_FoamColor("FoamColor", Color) = (1024,1024,1024,0)
		_Edgedistance("Edge distance", Float) = 1
		_Edgepower("Edge power", Range( 0 , 1)) = 0.5213435
		_WaveMultiplier("Wave Multiplier", Float) = 1
		_Float0("Float 0", Range( 0 , 1)) = 0
		_TextureSample0("Texture Sample 0", 2D) = "bump" {}
		_DistortionMove("Distortion Move", Vector) = (0,0,0,0)
		_DistiortionDirection("Distiortion Direction", Vector) = (0,0,0,0)
		_Float3("Float 3", Range( 0 , 1)) = 1
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_EdgeScale("Edge Scale", Float) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
		};

		uniform float _PrimaryNoiseScale;
		uniform float _PrimaryNoiseAngle;
		uniform float2 _PrimaryNoiseScroll;
		uniform float _SecondaryNoiseScale;
		uniform float _SecondaryNoiseAngle;
		uniform float2 _SecondaryNoiseScroll;
		uniform float _Float0;
		uniform float _WaveMultiplier;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform sampler2D _TextureSample0;
		uniform float3 _DistortionMove;
		uniform float3 _DistiortionDirection;
		uniform float _CutoffMin;
		uniform float _CutoffMax;
		uniform float4 _WaterColor;
		uniform float _Edgepower;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Edgedistance;
		uniform sampler2D _TextureSample1;
		uniform float _EdgeScale;
		uniform float _Float3;
		uniform float4 _FoamColor;
		uniform float _Tesselation;


		float2 voronoihash5( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi5( float2 v, float time, inout float2 id, float smoothness )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mr = 0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash5( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = g - f + o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return F1;
		}


		float2 voronoihash28( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi28( float2 v, float time, inout float2 id, float smoothness )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mr = 0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash28( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = g - f + o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return F1;
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			float4 temp_cast_4 = (_Tesselation).xxxx;
			return temp_cast_4;
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float time5 = ( _Time.y * _PrimaryNoiseAngle );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 appendResult4 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float2 coords5 = ( appendResult4 + (0.0*1.0 + ( _Time.y * _PrimaryNoiseScroll ).x) ).xy * _PrimaryNoiseScale;
			float2 id5 = 0;
			float voroi5 = voronoi5( coords5, time5,id5, 0 );
			float PrimaryNoise15 = voroi5;
			float time28 = ( _Time.y * _SecondaryNoiseAngle );
			float4 appendResult22 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float2 coords28 = ( appendResult22 + (0.0*1.0 + ( _Time.y * _SecondaryNoiseScroll ).x) ).xy * _SecondaryNoiseScale;
			float2 id28 = 0;
			float voroi28 = voronoi28( coords28, time28,id28, 0 );
			float SecondaryNoise29 = voroi28;
			float temp_output_34_0 = ( PrimaryNoise15 * SecondaryNoise29 );
			v.vertex.xyz += ( (0.0 + (temp_output_34_0 - 0.0) * (_Float0 - 0.0) / (1.0 - 0.0)) * float3(0,0,1) * _WaveMultiplier );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 temp_cast_1 = ((0.0*1.0 + ( ( _Time.y * _DistortionMove ) + float3( 0,0,0 ) ).x)).xx;
			float4 screenColor103 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ase_screenPosNorm + ( ( ase_screenPosNorm * float4( UnpackNormal( tex2D( _TextureSample0, temp_cast_1 ) ) , 0.0 ) ) * float4( _DistiortionDirection , 0.0 ) ) ).xy);
			float4 distortion111 = screenColor103;
			float time5 = ( _Time.y * _PrimaryNoiseAngle );
			float3 ase_worldPos = i.worldPos;
			float4 appendResult4 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float2 coords5 = ( appendResult4 + (0.0*1.0 + ( _Time.y * _PrimaryNoiseScroll ).x) ).xy * _PrimaryNoiseScale;
			float2 id5 = 0;
			float voroi5 = voronoi5( coords5, time5,id5, 0 );
			float PrimaryNoise15 = voroi5;
			float time28 = ( _Time.y * _SecondaryNoiseAngle );
			float4 appendResult22 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float2 coords28 = ( appendResult22 + (0.0*1.0 + ( _Time.y * _SecondaryNoiseScroll ).x) ).xy * _SecondaryNoiseScale;
			float2 id28 = 0;
			float voroi28 = voronoi28( coords28, time28,id28, 0 );
			float SecondaryNoise29 = voroi28;
			float temp_output_34_0 = ( PrimaryNoise15 * SecondaryNoise29 );
			float smoothstepResult35 = smoothstep( _CutoffMin , _CutoffMax , temp_output_34_0);
			float Foam41 = smoothstepResult35;
			o.Albedo = ( distortion111 + ( ( 1.0 - Foam41 ) * _WaterColor ) ).rgb;
			float screenDepth60 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth60 = abs( ( screenDepth60 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Edgedistance ) );
			float4 appendResult124 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 temp_cast_11 = (_Float3).xxxx;
			float4 temp_cast_12 = (0.0).xxxx;
			float4 temp_cast_13 = (1.0).xxxx;
			float4 clampResult75 = clamp( ( _Edgepower * ( ( 1.0 - distanceDepth60 ) + step( tex2D( _TextureSample1, (appendResult124*_EdgeScale + 0.0).xy ) , temp_cast_11 ) ) ) , temp_cast_12 , temp_cast_13 );
			float4 Edge65 = clampResult75;
			float4 temp_cast_14 = (0.0).xxxx;
			float4 temp_cast_15 = (1.0).xxxx;
			float4 clampResult146 = clamp( ( ( Edge65 * _FoamColor ) + ( Foam41 * _FoamColor ) ) , temp_cast_14 , temp_cast_15 );
			float4 blendedFoam80 = clampResult146;
			o.Emission = blendedFoam80.rgb;
			float clampResult58 = clamp( ( _WaterColor.a + Foam41 ) , 0.0 , 1.0 );
			o.Alpha = clampResult58;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
				float3 worldPos : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
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
				vertexDataFunc( v );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
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
8;81;1563;679;4468.602;2841.525;4.462237;True;False
Node;AmplifyShaderEditor.CommentaryNode;16;-2608.535,-495.325;Inherit;False;1315.539;674.4221;Comment;12;7;9;3;10;4;8;13;11;6;12;5;15;Primary Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;17;-2602.381,344.4882;Inherit;False;1315.539;674.4221;Comment;12;29;28;27;26;25;24;23;22;21;20;19;18;Secondary Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;9;-2558.535,-135.1385;Inherit;False;Property;_PrimaryNoiseScroll;Primary Noise Scroll;2;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;7;-2529.911,-220.8721;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;18;-2523.757,618.9411;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;19;-2552.381,704.6747;Inherit;False;Property;_SecondaryNoiseScroll;Secondary Noise Scroll;3;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-2320.381,637.6747;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;3;-2426.255,-445.325;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;123;-1823.932,1980.901;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;20;-2420.101,394.4882;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-2326.535,-202.1385;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;23;-2163.381,562.6747;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-1463.419,2223.319;Inherit;False;Property;_EdgeScale;Edge Scale;21;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;22;-2166.101,414.4882;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;8;-2169.535,-277.1385;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;124;-1546.932,1982.901;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2488.616,902.9104;Inherit;False;Property;_SecondaryNoiseAngle;Secondary Noise Angle;5;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2494.77,63.09716;Inherit;False;Property;_PrimaryNoiseAngle;Primary Noise Angle;4;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;4;-2172.255,-425.325;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;85;-1219.14,1393.385;Inherit;False;1718.052;464.4252;Comment;9;65;75;63;64;62;60;61;144;145;Edge;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-1985.38,448.6747;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1915.236,-214.0708;Inherit;False;Property;_PrimaryNoiseScale;Primary Noise Scale;0;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;142;-1288.419,2028.319;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1909.082,625.7424;Inherit;False;Property;_SecondaryNoiseScale;Secondary Noise Scale;1;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-2147.77,-116.9028;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-1991.534,-391.1385;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;133;-1386.142,-2072.018;Inherit;False;2894.177;557.4839;Comment;14;93;108;94;107;97;98;96;109;99;101;100;103;106;111;Distortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-1169.14,1458.369;Inherit;False;Property;_Edgedistance;Edge distance;11;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-2141.616,722.9105;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;93;-1307.435,-1959.124;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;108;-1336.142,-1798.398;Inherit;False;Property;_DistortionMove;Distortion Move;17;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;141;-1075.904,1965.91;Inherit;True;Property;_TextureSample1;Texture Sample 1;20;0;Create;True;0;0;False;0;-1;9fbef4b79ca3b784ba023cb1331520d5;9fbef4b79ca3b784ba023cb1331520d5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VoronoiNode;28;-1785.101,412.4882;Inherit;False;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.VoronoiNode;5;-1791.255,-427.325;Inherit;False;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.RangedFloatNode;140;-956.4912,2229.662;Inherit;False;Property;_Float3;Float 3;19;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;60;-916.8604,1443.385;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;62;-616.3802,1444.261;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;139;-618.4751,2172.245;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-1510.842,407.1509;Inherit;False;SecondaryNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;42;-2563.181,-1138.284;Inherit;False;1221.293;493.0002;Comment;7;33;32;34;35;41;36;37;Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-1074.335,-1870.624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-1516.996,-432.6623;Inherit;True;PrimaryNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;107;-833.975,-1741.435;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-2496.181,-1088.284;Inherit;False;15;PrimaryNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;138;-443.5779,1952.973;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-2513.181,-881.2835;Inherit;False;29;SecondaryNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-800.2496,1615.666;Inherit;False;Property;_Edgepower;Edge power;12;0;Create;True;0;0;False;0;0.5213435;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-2177.181,-761.2834;Inherit;False;Property;_CutoffMax;Cutoff Max;8;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-2166.181,-870.2835;Inherit;False;Property;_CutoffMin;Cutoff Min;6;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-2209.181,-1014.284;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-217.1637,1460.708;Inherit;False;Constant;_Float2;Float 2;22;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;97;-641.5353,-1780.724;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-66.1637,1658.708;Inherit;False;Constant;_Float1;Float 1;22;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-305.2674,1579.065;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;98;-291.4509,-2022.018;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;96;-386.5354,-1809.724;Inherit;True;Property;_TextureSample0;Texture Sample 0;16;0;Create;True;0;0;False;0;-1;77fdad851e93f394c9f8a1b1a63b56f3;77fdad851e93f394c9f8a1b1a63b56f3;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;35;-1783.182,-1011.284;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;75;-41.43644,1506.521;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;86;-2471.086,1169.907;Inherit;False;1007.627;765.2697;Comment;11;77;51;76;83;82;84;79;80;146;147;148;Blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;124.1056,1496.898;Inherit;False;Edge;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-1565.888,-1018.663;Inherit;False;Foam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;31.54911,-1889.018;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector3Node;109;-37.13126,-1702.534;Inherit;False;Property;_DistiortionDirection;Distiortion Direction;18;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;76;-2382.228,1616.507;Inherit;False;41;Foam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;51;-2401.128,1719.177;Inherit;False;Property;_FoamColor;FoamColor;10;1;[HDR];Create;True;0;0;False;0;1024,1024,1024,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;283.5491,-1716.018;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;-2353.228,1219.907;Inherit;False;65;Edge;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;574.5491,-1816.018;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-2106.581,1551.787;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-2162.086,1321.305;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-1909.259,1395.964;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;103;953.7488,-1820.636;Inherit;False;Global;_GrabScreen0;Grab Screen 0;19;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;148;-1946.651,1604.315;Inherit;False;Constant;_Float5;Float 5;22;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-894.8449,-1334.506;Inherit;False;41;Foam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-1924.651,1685.315;Inherit;False;Constant;_Float4;Float 4;22;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;45;-656.0451,-1302.406;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;1284.035,-1811.567;Inherit;False;distortion;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-475.1467,-871.1932;Inherit;False;41;Foam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-2134.103,-1248.154;Inherit;False;Property;_Float0;Float 0;15;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;146;-1803.651,1521.315;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;43;-674.1838,-1140.14;Inherit;False;Property;_WaterColor;WaterColor;9;1;[HDR];Create;True;0;0;False;0;0,1,0.8411126,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-1688.259,1400.964;Inherit;False;blendedFoam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-168.8888,-888.0013;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;88;-381.9096,-571.0904;Inherit;False;Constant;_Vector0;Vector 0;14;0;Create;True;0;0;False;0;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;90;-329.336,-350.9714;Inherit;False;Property;_WaveMultiplier;Wave Multiplier;14;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-354.585,-1427.628;Inherit;False;111;distortion;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-406.0451,-1211.206;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;91;-1781.382,-1406.021;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;122;-2575.682,2462.831;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;83;-2421.086,1396.305;Inherit;False;Property;_EdgeColor;Edge Color;13;1;[HDR];Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-121.98,-662.5281;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;58;-18.88875,-881.0014;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;104;-26.23665,-1358.952;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-64.10456,-527.0654;Inherit;False;Property;_Tesselation;Tesselation;7;0;Create;True;0;0;False;0;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;128;-3022.653,2671.154;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;132;-3003.139,2773.531;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;81;-136.328,-1035.901;Inherit;False;80;blendedFoam;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;126;-3063.653,2530.154;Inherit;False;Constant;_EdgeNoiseScroll;Edge Noise Scroll;19;0;Create;True;0;0;False;0;0.5,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;87;-454.1513,-665.5895;Inherit;False;41;Foam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;-2786.653,2508.154;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldReflectionVector;106;-1111.975,-1699.435;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;197.9878,-1204.635;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;21;0;18;0
WireConnection;21;1;19;0
WireConnection;10;0;7;0
WireConnection;10;1;9;0
WireConnection;23;2;21;0
WireConnection;22;0;20;1
WireConnection;22;1;20;3
WireConnection;8;2;10;0
WireConnection;124;0;123;1
WireConnection;124;1;123;3
WireConnection;4;0;3;1
WireConnection;4;1;3;3
WireConnection;25;0;22;0
WireConnection;25;1;23;0
WireConnection;142;0;124;0
WireConnection;142;1;143;0
WireConnection;12;0;7;0
WireConnection;12;1;13;0
WireConnection;11;0;4;0
WireConnection;11;1;8;0
WireConnection;27;0;18;0
WireConnection;27;1;24;0
WireConnection;141;1;142;0
WireConnection;28;0;25;0
WireConnection;28;1;27;0
WireConnection;28;2;26;0
WireConnection;5;0;11;0
WireConnection;5;1;12;0
WireConnection;5;2;6;0
WireConnection;60;0;61;0
WireConnection;62;0;60;0
WireConnection;139;0;141;0
WireConnection;139;1;140;0
WireConnection;29;0;28;0
WireConnection;94;0;93;0
WireConnection;94;1;108;0
WireConnection;15;0;5;0
WireConnection;107;0;94;0
WireConnection;138;0;62;0
WireConnection;138;1;139;0
WireConnection;34;0;33;0
WireConnection;34;1;32;0
WireConnection;97;2;107;0
WireConnection;63;0;64;0
WireConnection;63;1;138;0
WireConnection;96;1;97;0
WireConnection;35;0;34;0
WireConnection;35;1;36;0
WireConnection;35;2;37;0
WireConnection;75;0;63;0
WireConnection;75;1;145;0
WireConnection;75;2;144;0
WireConnection;65;0;75;0
WireConnection;41;0;35;0
WireConnection;99;0;98;0
WireConnection;99;1;96;0
WireConnection;101;0;99;0
WireConnection;101;1;109;0
WireConnection;100;0;98;0
WireConnection;100;1;101;0
WireConnection;84;0;76;0
WireConnection;84;1;51;0
WireConnection;82;0;77;0
WireConnection;82;1;51;0
WireConnection;79;0;82;0
WireConnection;79;1;84;0
WireConnection;103;0;100;0
WireConnection;45;0;44;0
WireConnection;111;0;103;0
WireConnection;146;0;79;0
WireConnection;146;1;148;0
WireConnection;146;2;147;0
WireConnection;80;0;146;0
WireConnection;57;0;43;4
WireConnection;57;1;49;0
WireConnection;46;0;45;0
WireConnection;46;1;43;0
WireConnection;91;0;34;0
WireConnection;91;4;92;0
WireConnection;122;2;127;0
WireConnection;89;0;91;0
WireConnection;89;1;88;0
WireConnection;89;2;90;0
WireConnection;58;0;57;0
WireConnection;104;0;112;0
WireConnection;104;1;46;0
WireConnection;127;0;126;0
WireConnection;127;1;132;4
WireConnection;0;0;104;0
WireConnection;0;2;81;0
WireConnection;0;9;58;0
WireConnection;0;11;89;0
WireConnection;0;14;53;0
ASEEND*/
//CHKSM=6C79E2DF5FAA8116C1E83012931F98238F202BD8