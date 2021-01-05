// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water2"
{
	Properties
	{
		_WaveSpeed("Wave Speed", Float) = 1
		_WaveStretch("Wave Stretch", Vector) = (0.23,0.01,0,0)
		_WaveTile("Wave Tile", Float) = 1
		_Tesselation("Tesselation", Float) = 10
		_WaveHeight("Wave Height", Float) = 1
		_TopColor("Top Color", Color) = (0,0.9441657,1,1)
		_WaterColor("Water Color", Color) = (0,0.7720158,1,0)
		_Distance("Distance", Float) = 1
		_EdgePower("Edge Power", Range( 0 , 1)) = 0.5
		_NormalMap("Normal Map", 2D) = "white" {}
		_NormalTile("Normal Tile", Float) = 1
		_NormalSpeed("Normal Speed", Float) = 1
		_PanD2("Pan D2", Vector) = (-1,0,0,0)
		_PanDirection("Pan Direction", Vector) = (1,0,0,0)
		_NormalStrenght("Normal Strenght", Range( 0 , 1)) = 1
		_EdgeFoam("Edge Foam", 2D) = "white" {}
		_IdkFloat1("IdkFloat1", Float) = 10
		_EdgeFoamTile("Edge Foam Tile", Float) = 1
		_Refreactamount("Refreact amount", Float) = 0.1
		_Foammask("Foam mask", Float) = 0.03
		_Depth("Depth", Float) = -4
		_TesselationRange("Tesselation Range", Float) = 80
		_Colorworldlerp("Color world lerp", Range( 0 , 1)) = 0
		_SeaFoamStrenght("SeaFoamStrenght", Range( 0 , 1)) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha noshadow vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
		};

		uniform float _WaveHeight;
		uniform float _WaveSpeed;
		uniform float2 _WaveStretch;
		uniform float _WaveTile;
		uniform sampler2D _NormalMap;
		uniform float _NormalStrenght;
		uniform float2 _PanDirection;
		uniform float _NormalSpeed;
		uniform float _NormalTile;
		uniform float2 _PanD2;
		uniform float4 _WaterColor;
		uniform float _Colorworldlerp;
		uniform float4 _TopColor;
		uniform sampler2D _EdgeFoam;
		uniform float _IdkFloat1;
		uniform float _EdgeFoamTile;
		uniform float _Foammask;
		uniform float _SeaFoamStrenght;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _Refreactamount;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Depth;
		uniform float _Distance;
		uniform float _EdgePower;
		uniform float _TesselationRange;
		uniform float _Tesselation;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, 0.0,_TesselationRange,_Tesselation);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float2 _WaveDirection = float2(1,0);
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 appendResult10 = (float4(ase_worldPos.x , ase_worldPos.z , ase_worldPos.z , 0.0));
			float4 worldSpace11 = appendResult10;
			float4 waveTileUV21 = ( ( worldSpace11 * float4( _WaveStretch, 0.0 , 0.0 ) ) * _WaveTile );
			float2 panner3 = ( ( _Time.y * _WaveSpeed ) * _WaveDirection + waveTileUV21.xy);
			float simplePerlin2D1 = snoise( panner3 );
			float2 panner23 = ( _WaveSpeed * _WaveDirection + ( waveTileUV21 * float4( 0.1,0.1,0,0 ) ).xy);
			float simplePerlin2D24 = snoise( panner23 );
			float temp_output_29_0 = ( simplePerlin2D1 + simplePerlin2D24 );
			float3 waveHeight36 = ( ( float3(0,1,0) * _WaveHeight ) * temp_output_29_0 );
			v.vertex.xyz += waveHeight36;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 appendResult10 = (float4(ase_worldPos.x , ase_worldPos.z , ase_worldPos.z , 0.0));
			float4 worldSpace11 = appendResult10;
			float4 temp_output_61_0 = ( worldSpace11 * _NormalTile );
			float2 panner66 = ( 1.0 * _Time.y * ( _PanDirection * _NormalSpeed ) + temp_output_61_0.xy);
			float2 panner67 = ( 1.0 * _Time.y * ( ( _NormalSpeed * 3.0 ) * _PanD2 ) + ( temp_output_61_0 * ( _NormalTile * 5.0 ) ).xy);
			float3 normals76 = BlendNormals( UnpackScaleNormal( tex2D( _NormalMap, panner66 ), _NormalStrenght ) , UnpackScaleNormal( tex2D( _NormalMap, panner67 ), _NormalStrenght ) );
			o.Normal = normals76;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 lerpResult134 = lerp( _WaterColor , ase_lightColor , _Colorworldlerp);
			float2 panner102 = ( 1.0 * _Time.y * float2( 0.1,0.2 ) + ( worldSpace11 * _Foammask ).xy);
			float simplePerlin2D101 = snoise( panner102 );
			float4 clampResult109 = clamp( ( tex2D( _EdgeFoam, ( ( worldSpace11 / _IdkFloat1 ) * _EdgeFoamTile ).xy ) * simplePerlin2D101 ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 seafoam98 = clampResult109;
			float4 lerpResult135 = lerp( ( _TopColor + seafoam98 ) , ase_lightColor , _Colorworldlerp);
			float2 _WaveDirection = float2(1,0);
			float4 waveTileUV21 = ( ( worldSpace11 * float4( _WaveStretch, 0.0 , 0.0 ) ) * _WaveTile );
			float2 panner3 = ( ( _Time.y * _WaveSpeed ) * _WaveDirection + waveTileUV21.xy);
			float simplePerlin2D1 = snoise( panner3 );
			float2 panner23 = ( _WaveSpeed * _WaveDirection + ( waveTileUV21 * float4( 0.1,0.1,0,0 ) ).xy);
			float simplePerlin2D24 = snoise( panner23 );
			float temp_output_29_0 = ( simplePerlin2D1 + simplePerlin2D24 );
			float wavePositive34 = temp_output_29_0;
			float clampResult46 = clamp( wavePositive34 , 0.0 , 1.0 );
			float4 lerpResult43 = lerp( lerpResult134 , lerpResult135 , ( clampResult46 * _SeaFoamStrenght ));
			float4 albedo47 = lerpResult43;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor118 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( (ase_grabScreenPosNorm).xyzw + float4( ( _Refreactamount * normals76 ) , 0.0 ) ).xy);
			float4 clampResult119 = clamp( screenColor118 , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 refraction120 = clampResult119;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth123 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth123 = abs( ( screenDepth123 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Depth ) );
			float clampResult125 = clamp( ( 1.0 - distanceDepth123 ) , 0.0 , 1.0 );
			float Depth126 = clampResult125;
			float4 lerpResult127 = lerp( albedo47 , refraction120 , Depth126);
			o.Albedo = lerpResult127.rgb;
			float screenDepth50 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth50 = abs( ( screenDepth50 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Distance ) );
			float4 clampResult56 = clamp( ( ( ( 1.0 - distanceDepth50 ) + tex2D( _EdgeFoam, ( ( worldSpace11 / 10.0 ) * _EdgeFoamTile ).xy ) ) * _EdgePower ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 edge54 = clampResult56;
			o.Emission = edge54.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
0;24;1920;1035;2351.55;-2228.68;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;12;-2662.269,-1217.584;Inherit;False;696.3931;252.3;Comment;3;9;10;11;Worldspace;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;9;-2594.269,-1167.584;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;10;-2378.369,-1148.284;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-2189.876,-1150.654;Inherit;False;worldSpace;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-2782.857,-732.7287;Inherit;False;11;worldSpace;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;15;-2768.095,-525.8663;Inherit;False;Property;_WaveStretch;Wave Stretch;1;0;Create;True;0;0;False;0;0.23,0.01;0.15,0.02;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;77;1442.269,1131.431;Inherit;False;2718.649;1244.547;Comment;19;70;66;72;68;65;64;61;59;71;60;73;69;67;58;62;63;74;75;76;Normal map;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2525.96,-610.942;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-2391.99,-501.0936;Inherit;False;Property;_WaveTile;Wave Tile;2;0;Create;True;0;0;False;0;1;0.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;1492.269,1181.431;Inherit;True;11;worldSpace;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;72;2179.192,1717.824;Inherit;False;Property;_NormalSpeed;Normal Speed;11;0;Create;True;0;0;False;0;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-2158.094,-598.8661;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;60;1503.327,1468.661;Inherit;False;Property;_NormalTile;Normal Tile;10;0;Create;True;0;0;False;0;1;0.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;110;-1958.471,2251.873;Inherit;False;2129.814;803.0769;Comment;15;105;104;97;93;103;95;96;102;101;108;109;106;94;98;92;Sea foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;68;2130.504,1443.851;Inherit;False;Property;_PanDirection;Pan Direction;13;0;Create;True;0;0;False;0;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;93;-1730.965,2485.873;Inherit;False;Property;_IdkFloat1;IdkFloat1;16;0;Create;True;0;0;False;0;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;-1908.471,2805.259;Inherit;False;11;worldSpace;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;38;-1773.171,-453.7609;Inherit;False;1627.339;798.6386;Comment;14;28;7;6;8;27;25;4;22;23;3;1;24;29;34;Wave Patterns;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-1710.291,2332.791;Inherit;False;11;worldSpace;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-1905.518,2938.95;Inherit;False;Property;_Foammask;Foam mask;20;0;Create;True;0;0;False;0;0.03;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;69;2291.741,2211.978;Inherit;False;Property;_PanD2;Pan D2;12;0;Create;True;0;0;False;0;-1,0;-1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;2361.417,1948.516;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;1762.441,2043.193;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-1931.907,-603.9194;Inherit;False;waveTileUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;1962.525,1353.306;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;28;-1490.554,140.9205;Inherit;False;21;waveTileUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;6;-1711.171,-187.2847;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;2545.897,2176.701;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1723.171,-60.28463;Inherit;False;Property;_WaveSpeed;Wave Speed;0;0;Create;True;0;0;False;0;1;0.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;2490.637,1426.824;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;89;-1840.916,1484.588;Inherit;False;1224.856;619.9955;Comment;6;84;83;85;86;82;81;Edge foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;1955.65,2036.151;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;95;-1373.965,2301.873;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-1507.807,2122.094;Inherit;False;Property;_EdgeFoamTile;Edge Foam Tile;18;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-1646.211,2799.875;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;4;-1285.185,-41.78284;Inherit;False;Constant;_WaveDirection;Wave Direction;0;0;Create;True;0;0;False;0;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1250.388,177.5967;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.1,0.1,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-1233.342,-403.7609;Inherit;False;21;waveTileUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-1468.171,-195.2847;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;27;-1551.281,225.2463;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;58;1630.065,1643.827;Inherit;True;Property;_NormalMap;Normal Map;9;0;Create;True;0;0;False;0;None;None;True;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-1141.213,2350.43;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;75;2818.187,1679.425;Inherit;False;Property;_NormalStrenght;Normal Strenght;14;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;81;-1776.381,1544.737;Inherit;True;Property;_EdgeFoam;Edge Foam;15;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;102;-1338.59,2782.121;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.2;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;66;2803.141,1214.337;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;67;2820.666,2046.353;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;63;3205.981,1883.751;Inherit;True;Property;_TextureSample1;Texture Sample 1;11;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;62;3194.957,1445.741;Inherit;True;Property;_TextureSample0;Texture Sample 0;11;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;101;-1064.168,2742.219;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;23;-1011.585,185.8776;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;3;-1028.029,-300.7792;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;92;-927.1119,2316.2;Inherit;True;Property;_TextureSample3;Texture Sample 3;17;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-532.4265,2548.994;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1;-794.0401,-245.5573;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;74;3664.674,1708.358;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;24;-771.7811,132.9395;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;76;3936.918,1690.125;Inherit;False;normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-521.8083,-50.08253;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-1790.916,1988.583;Inherit;False;Constant;_Float0;Float 0;16;0;Create;True;0;0;False;0;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;80;-1351.944,834.2922;Inherit;False;2266.239;499.5362;Comment;8;88;54;56;52;53;51;50;49;Edge;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;122;-4738.564,282.7668;Inherit;False;1783.249;620.4152;Comment;9;113;114;117;118;119;120;112;116;115;refraction;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;109;-289.2546,2549.324;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;-1770.242,1835.501;Inherit;False;11;worldSpace;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;-4639.749,781.7675;Inherit;False;76;normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-4644.601,647.6239;Inherit;False;Property;_Refreactamount;Refreact amount;19;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-52.65701,2501.833;Inherit;False;seafoam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1301.944,884.2922;Inherit;False;Property;_Distance;Distance;7;0;Create;True;0;0;False;0;1;1.44;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-369.8323,93.26219;Inherit;False;wavePositive;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;112;-4688.564,332.7668;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;84;-1433.916,1804.583;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;79;685.174,-1276.567;Inherit;False;1633.501;971.5581;Comment;14;47;43;135;44;46;134;41;133;136;100;42;99;137;138;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-4606.302,12.59877;Inherit;False;Property;_Depth;Depth;21;0;Create;True;0;0;False;0;-4;-4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-4343.562,649.182;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-1201.164,1853.141;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DepthFade;50;-1017.226,893.0894;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;769.8892,-733.515;Inherit;False;98;seafoam;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;755.6479,-595.9772;Inherit;False;34;wavePositive;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;42;703.9436,-984.0135;Inherit;False;Property;_TopColor;Top Color;5;0;Create;True;0;0;False;0;0,0.9441657,1,1;0,0.7645757,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;116;-4282.25,416.0665;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;46;1003.029,-617.4164;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;138;966.2253,-393.0231;Inherit;False;Property;_SeaFoamStrenght;SeaFoamStrenght;24;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;133;893.4138,-1039.676;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;117;-4023.559,541.3064;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;39;-787.8758,-1031.653;Inherit;False;915.7945;415.0003;Comment;5;30;32;31;35;36;Wave Height;1,1,1,1;0;0
Node;AmplifyShaderEditor.DepthFade;123;-4394.913,-97.58298;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;41;760.0233,-1219.924;Inherit;False;Property;_WaterColor;Water Color;6;0;Create;True;0;0;False;0;0,0.7720158,1,0;0,1,0.9583272,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;99;1034.125,-807.6965;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;51;-698.2261,943.0894;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;82;-936.0599,1570.473;Inherit;True;Property;_TextureSample2;Texture Sample 2;16;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;136;1151.538,-997.0009;Inherit;False;Property;_Colorworldlerp;Color world lerp;23;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;118;-3770.76,566.7064;Inherit;False;Global;_GrabScreen0;Grab Screen 0;19;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;32;-737.8758,-732.6529;Inherit;False;Property;_WaveHeight;Wave Height;4;0;Create;True;0;0;False;0;1;0.93;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;129;-4129.52,-92.62869;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;135;1281.08,-816.0332;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-392.0577,958.6561;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;30;-717.8758,-981.6532;Inherit;False;Constant;_waveup;wave up;4;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;134;1420.79,-1128.706;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-899.6573,1097.104;Inherit;False;Property;_EdgePower;Edge Power;8;0;Create;True;0;0;False;0;0.5;0.595;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;1384.225,-623.0231;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-516.8755,-904.6531;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;43;1595.537,-913.6135;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;84.74246,947.1035;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;119;-3442.316,567.5867;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;125;-3947.509,-97.84;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;1900.315,-888.9976;Inherit;False;albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-309.6094,-909.3802;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;120;-3179.316,573.5867;Inherit;False;refraction;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;56;263.3647,969.205;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-3656.509,-90.84;Inherit;False;Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;1605.686,-30.38874;Inherit;False;47;albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;1603.089,157.8892;Inherit;False;126;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;556.7697,947.2352;Inherit;False;edge;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;18;1659.765,681.6787;Inherit;False;Property;_Tesselation;Tesselation;3;0;Create;True;0;0;False;0;10;110.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-96.08129,-881.4886;Inherit;False;waveHeight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;1612.989,53.12543;Inherit;False;120;refraction;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;131;1746.979,834.7484;Inherit;False;Property;_TesselationRange;Tesselation Range;22;0;Create;True;0;0;False;0;80;80;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-1419.856,2539.383;Inherit;False;Property;_Seafoamtile;Sea foam tile;17;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-552.5932,2911.597;Inherit;False;foammask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;127;1891.78,88.34973;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;1922.443,259.9413;Inherit;False;76;normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;132;177.8306,-774.632;Inherit;False;unity_AmbientSky;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;1843.162,458.838;Inherit;False;36;waveHeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DistanceBasedTessNode;130;1945.438,703.5552;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;2030.375,938.1683;Inherit;False;106;foammask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;1863.945,351.5163;Inherit;False;54;edge;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2269.978,260.7093;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Water2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;10;0;9;1
WireConnection;10;1;9;3
WireConnection;10;2;9;3
WireConnection;11;0;10;0
WireConnection;14;0;13;0
WireConnection;14;1;15;0
WireConnection;16;0;14;0
WireConnection;16;1;17;0
WireConnection;73;0;72;0
WireConnection;64;0;60;0
WireConnection;21;0;16;0
WireConnection;61;0;59;0
WireConnection;61;1;60;0
WireConnection;71;0;73;0
WireConnection;71;1;69;0
WireConnection;70;0;68;0
WireConnection;70;1;72;0
WireConnection;65;0;61;0
WireConnection;65;1;64;0
WireConnection;95;0;97;0
WireConnection;95;1;93;0
WireConnection;103;0;104;0
WireConnection;103;1;105;0
WireConnection;25;0;28;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;27;0;7;0
WireConnection;96;0;95;0
WireConnection;96;1;87;0
WireConnection;102;0;103;0
WireConnection;66;0;61;0
WireConnection;66;2;70;0
WireConnection;67;0;65;0
WireConnection;67;2;71;0
WireConnection;63;0;58;0
WireConnection;63;1;67;0
WireConnection;63;5;75;0
WireConnection;62;0;58;0
WireConnection;62;1;66;0
WireConnection;62;5;75;0
WireConnection;101;0;102;0
WireConnection;23;0;25;0
WireConnection;23;2;4;0
WireConnection;23;1;27;0
WireConnection;3;0;22;0
WireConnection;3;2;4;0
WireConnection;3;1;8;0
WireConnection;92;0;81;0
WireConnection;92;1;96;0
WireConnection;108;0;92;0
WireConnection;108;1;101;0
WireConnection;1;0;3;0
WireConnection;74;0;62;0
WireConnection;74;1;63;0
WireConnection;24;0;23;0
WireConnection;76;0;74;0
WireConnection;29;0;1;0
WireConnection;29;1;24;0
WireConnection;109;0;108;0
WireConnection;98;0;109;0
WireConnection;34;0;29;0
WireConnection;84;0;83;0
WireConnection;84;1;85;0
WireConnection;114;0;113;0
WireConnection;114;1;115;0
WireConnection;86;0;84;0
WireConnection;86;1;87;0
WireConnection;50;0;49;0
WireConnection;116;0;112;0
WireConnection;46;0;44;0
WireConnection;117;0;116;0
WireConnection;117;1;114;0
WireConnection;123;0;124;0
WireConnection;99;0;42;0
WireConnection;99;1;100;0
WireConnection;51;0;50;0
WireConnection;82;0;81;0
WireConnection;82;1;86;0
WireConnection;118;0;117;0
WireConnection;129;0;123;0
WireConnection;135;0;99;0
WireConnection;135;1;133;0
WireConnection;135;2;136;0
WireConnection;88;0;51;0
WireConnection;88;1;82;0
WireConnection;134;0;41;0
WireConnection;134;1;133;0
WireConnection;134;2;136;0
WireConnection;137;0;46;0
WireConnection;137;1;138;0
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;43;0;134;0
WireConnection;43;1;135;0
WireConnection;43;2;137;0
WireConnection;52;0;88;0
WireConnection;52;1;53;0
WireConnection;119;0;118;0
WireConnection;125;0;129;0
WireConnection;47;0;43;0
WireConnection;35;0;31;0
WireConnection;35;1;29;0
WireConnection;120;0;119;0
WireConnection;56;0;52;0
WireConnection;126;0;125;0
WireConnection;54;0;56;0
WireConnection;36;0;35;0
WireConnection;106;0;101;0
WireConnection;127;0;48;0
WireConnection;127;1;121;0
WireConnection;127;2;128;0
WireConnection;130;0;18;0
WireConnection;130;2;131;0
WireConnection;0;0;127;0
WireConnection;0;1;78;0
WireConnection;0;2;55;0
WireConnection;0;11;37;0
WireConnection;0;14;130;0
ASEEND*/
//CHKSM=A99C6C03A43748218EE189D86C657773D5C1D9DA