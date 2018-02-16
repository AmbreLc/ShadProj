// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Skybox/FBMClouds" 
{
	Properties 
	{
		_Speed("Speed", Range(0,10)) = 1.0
		_Density("Density", Range(-100,100)) = 1.0
		_Border("Border", Range(0, 0.5)) = 0.1
		_TestUV("TestUV", Range(-1, 1)) = 0.5
		_ProjectionMode("Proj (1-ort 2-ster 3-eq 4-gnom)", Range(1, 4)) = 1

		_ColorSky("Sky color", Color) = (0, 0, 1, 1)
		_ColorHorizon("Horizon fog color", Color) = (1, 1, 1, 1)
		_SkyExponent("Horizon fog : size on sky", Range(0, 10)) = 8.5
		_CloudsExponent("Horizon fog : size on FBM", Range(1, 10)) = 3

		_Color1("Color A", Color) = (0.101961, 0.619608, 0.666667, 1)
		_Color2("Color B", Color) = (0.666667, 0.666667, 0.498039, 1)
		_Color3("Color C", Color) = (0 ,0, 0.164706, 1)
		_Color4("Color D", Color) = (0.666667, 1, 1, 1)
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	float _Speed;
	float _Density;
	float _Border;
	float _TestUV;
	int _ProjectionMode;


	float4 _ColorSky;
	float _SkyExponent;
	float4 _ColorHorizon;
	float4 _Color1;
	float4 _Color2;
	float4 _Color3;
	float4 _Color4;
	float _CloudsExponent;


	struct vertexInput
	{
		float4 vertex : POSITION;
		float4 texcoord : TEXCOORD0;
	};
	struct vertexOutput
	{
		float4 pos : SV_POSITION;
		float3 viewDir : TEXCOORD1;
		float4 uv : TEXCOORD0;

	};


	float random(in float2 _st)
	{
		return frac(sin(dot(_st.xy, float2(12.9898, 78.233)))* 43758.5453123);
	}

	// Based on Morgan McGuire @morgan3d
	// https://www.shadertoy.com/view/4dS3Wd
	float noise(in float2 _st)
	{
		int2 i = floor(_st);
		float2 f = frac(_st);

		// Four corners in 2D of a tile
		float a = random(i);
		float b = random(i + float2(1.0, 0.0));
		float c = random(i + float2(0.0, 1.0));
		float d = random(i + float2(1.0, 1.0));

		float2 u = f * f * (3.0 - 2.0 * f);

		return lerp(a, b, u.x) +
			(c - a)* u.y * (1.0 - u.x) +
			(d - b) * u.x * u.y;
	}

#define NUM_OCTAVES 5

	float fbm(in float2 _st)
	{
		float v = 0.0;
		float a = 0.5;

		float2 shift = float2(100, 0);
		// Rotate to reduce axial bias
		float2x2 rot = float2x2(cos(0.5), sin(0.5),
			-sin(0.5), cos(0.50));

		for (int i = 0; i < NUM_OCTAVES; ++i)
		{
			v += a * noise(_st);
			_st = mul(rot, _st) * 2.0 + shift;
			a *= 0.5;
		}
		return v;
	}


	vertexOutput vert(vertexInput input)
	{
		vertexOutput output;

		float4x4 modelMatrix = unity_ObjectToWorld;
		output.viewDir = mul(modelMatrix, input.vertex).xyz
			- _WorldSpaceCameraPos;
		output.pos = UnityObjectToClipPos(input.vertex);

		output.uv = normalize(mul(unity_ObjectToWorld, input.vertex));

		return output;
	}


	fixed4 frag(vertexOutput input) : COLOR
	{
		float sphereX = input.uv.x;
		float sphereZ = input.uv.y;

		float4 returnValue = float4(1, 1, 1, 1);

		float sphereY = sqrt(1.0 - pow(sphereX, 2.0) - pow(sphereZ, 2.0));

		float uvX;
		float uvY;

		if (_ProjectionMode == 1) //orthographic proj
		{			
			uvX = sphereX;
			uvY = sphereY;
		}
		else if (_ProjectionMode == 2) //stereographic projection
		{
			uvX = 2*sphereX / (1.0 - sphereZ);
			uvY = 2*sphereY / (1.0 - sphereZ);
		}
		else if (_ProjectionMode == 3) // equal area projection
		{
			uvX = sphereX * sqrt((1 + sphereZ) * 0.5f);
			uvY = sphereY * sqrt((1 + sphereZ) * 0.5f);
		}
		else if (_ProjectionMode == 4) // gnonomic projection
		{
			uvX = sphereX / sphereZ;
			uvY = sphereY / sphereZ;
		}

		float2 st = float2(uvX, uvY) * _Density;
		st += st * abs(sin(_Time*0.1)*0.1);

		float3 color = float3(0.8, 0.8, 0.8);

		float2 q = float2(0, 0);
		q.x = fbm(st + 0.0f* _Time * _Speed);
		q.y = fbm(st + float2(1, 0));

		float2 r = float2(0, 0);
		r.x = fbm(st + 1.0*q + float2(1.7, 9.2) + 0.15*_Time * _Speed);
		r.y = fbm(st + 1.0*q + float2(8.3, 2.8) + 0.126*_Time * _Speed);

		float f = fbm(st + r);

		color = lerp(_Color1.xyz,
			_Color2.xyz,
			clamp(f*f*4.0, 0.0, 1.0));

		color = lerp(color,
			_Color3.xyz,
			clamp(length(q), 0.0, 1.0));

		color = lerp(color,
			_Color4.xyz,
			clamp(length(r.x), 0.0, 1.0));


		// Lerp en y (ciel - horizon -brouillard)
		float p = input.uv.y;
		float p1 = 1 - pow(min(1, 1 - p), _SkyExponent);
		float p3 = 1 - pow(min(1, 1 + p), _CloudsExponent);
		float p2 = 1 - p1 - p3;

		half3 c_sky = _ColorSky * p1 + _ColorHorizon * p2 + half3((f*f*f + 0.6*f*f + 0.5*f)*color) * p3;

		if (c_sky.y > 0.1)
			returnValue.y = c_sky.y;
		returnValue.xz = c_sky.xz;



		//DebugUV
		//if ((uvY < _TestUV + _Border && uvY > _TestUV - _Border)
		//	|| (uvX < _TestUV + _Border && uvX > _TestUV - _Border))
		//	returnValue = float4(1, 1, 1, 1);


		// Suppression des artefacts


		return returnValue;
	}

	ENDCG


	SubShader 
	{
		Tags { "RenderType" = "Background" "Queue"="Background" }

		Pass
		{
			ZWrite Off
			Cull Off
			Fog{ Mode Off }
			CGPROGRAM
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}

