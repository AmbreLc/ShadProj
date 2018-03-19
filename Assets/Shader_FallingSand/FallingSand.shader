Shader "Custom/FadeUnderY" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_Speed("Speed", Range(0, 10)) = 1.0
		_Depth("Depth", Range(-10, -10000)) = -500.0
	}
	SubShader {
		Tags { "RenderType" = "Transparent""Queue"="Geometry" }
		LOD 300

		CGPROGRAM // _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows alpha:fade

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

//#pragma alpha
		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		float _Speed;
		float _Depth;


		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			float UV = IN.uv_MainTex.y + _Time * _Speed;
			UV = frac(UV);

			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, float2(IN.uv_MainTex.x, UV));
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = clamp(c.a * (1 - abs(IN.worldPos.y / _Depth)), 0.0, 1.0);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
