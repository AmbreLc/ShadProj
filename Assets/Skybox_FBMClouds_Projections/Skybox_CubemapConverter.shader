// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Skybox/CubemapConverter" 
{
	Properties 
	{
		_MainTex("Main texture", 2D) = "white" {}
		_CubemapOn("Cubemap On", Range(0, 1)) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	int _CubemapOn;


	struct vertexInput
	{
		float4 vertex : POSITION;
		float4 texcoord : TEXCOORD0;
	};
	struct vertexOutput
	{
		float4 pos : SV_POSITION;
		float4 uv : TEXCOORD0;

	};


	vertexOutput vert(vertexInput input)
	{
		vertexOutput output;

		float4x4 modelMatrix = unity_ObjectToWorld;
		output.pos = UnityObjectToClipPos(input.vertex);

		output.uv = float4(input.texcoord.xy, 0, 0);
		return output;
	}


	fixed4 frag(vertexOutput input) : COLOR
	{
		if (_CubemapOn == 0)
			return float4(input.uv.x, input.uv.y, 1, 0);
		else
		{
			float sphereX = input.uv.x;
			float sphereY = sqrt(1 - (input.uv.y*input.uv.y) - (input.uv.x*input.uv.x));
			float sphereZ = input.uv.y;

			float uvX = sphereX / (1 - sphereZ);
			float uvY = sphereY / (1 - sphereZ);

			return float4(uvX, uvY, 1, 0);
		}

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

