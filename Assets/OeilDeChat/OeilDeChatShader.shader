// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/OeilDeChat" 
{
	Properties 
	{
		_MainTex("Main texture", 2D) = "white" {}
		_Speed("Speed", Range(0,2)) = 1.0
		_UVMul("Truc", Range(1, 300)) = 15.0
	}


	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		float _Speed;
		float _UVMul;

		struct Input 
		{
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)


		float random(in float2 _st)
		{
			float a = sin(dot(_st.xy,
				float2(12.9898, 78.233)))*
				43758.5453123;
			int aInt = (int)a;

			return (a - aInt);
		}

		// Based on Morgan McGuire @morgan3d
		// https://www.shadertoy.com/view/4dS3Wd
		float noise(in float _st)
		{
			int i = (int)_st;
			float f = i - _st;

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

		void surf (Input IN, inout SurfaceOutputStandard o)
		{

			float2 st = IN.uv_MainTex.xy / _UVMul;
			// st += st * abs(sin(u_time*0.1)*3.0);
			float3 color = float3(0, 0, 0);

			float2 q = float2(0, 0);
			q.x = fbm(st + 0.00*_Time * _Speed);
			q.y = fbm(st + float(1.0));

			float2 r = float2(0, 0);
			r.x = fbm(st + 1.0*q + float2(1.7, 9.2) + 0.15*_Time * _Speed);
			r.y = fbm(st + 1.0*q + float2(8.3, 2.8) + 0.126*_Time * _Speed);

			float f = fbm(st + r);

			color = lerp(float3(0.101961, 0.619608, 0.666667),
				float3(0.666667, 0.666667, 0.498039),
				clamp((f*f)*4.0, 0.0, 1.0));

			color = lerp(color,
				float3(0, 0, 0.164706),
				clamp(length(q), 0.0, 1.0));

			color = lerp(color,
				float3(0.666667, 1, 1),
				clamp(length(r.x), 0.0, 1.0));

			o.Albedo = float4((f*f*f + .6*f*f + .5*f)*color, 1.);
		}
		ENDCG
	}
	FallBack "Diffuse"
}

