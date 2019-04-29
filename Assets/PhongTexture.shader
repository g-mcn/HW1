// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CM163/PhongTexture"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess("Shininess", Float) = 1.0
		_MainTex ("2k_mars", 2D) = "2k_mars.jpg" {}
		_MainTex2 ("2k_moon", 2D) = "2k_moon.jpg" {}
        
    }
    SubShader
    {
        Pass 
        {
			Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            float4 _LightColor0;
            float4 _Color;
            float4 _SpecularColor;
            float _Shininess;
            sampler2D _MainTex;
			sampler2D _MainTex2;
            
            struct vertexShaderInput 
            {
                float4 position: POSITION;
                float3 normal: NORMAL; 
                float2 uv: TEXCOORD0;
            };
            
            struct vertexShaderOutput
            {
                float4 position: SV_POSITION;
                float3 normal: NORMAL;
                float3 vertInWorldCoords: TEXCOORD1;
                float2 uv: TEXCOORD0;
            };
            
            vertexShaderOutput vert(vertexShaderInput v)
            {
                vertexShaderOutput o;
                o.vertInWorldCoords = mul(unity_ObjectToWorld, v.position);
                o.position = UnityObjectToClipPos(v.position);
                o.normal = v.normal;
                o.uv = v.uv;
                return o;
            }
            
            float4 frag(vertexShaderOutput i):SV_Target
            {
                float3 Ka = float3(1, 1, 1);
                float3 globalAmbient = float3(0.1, 0.1, 0.1);
                float3 ambientComponent = Ka * globalAmbient;

                float3 P = i.vertInWorldCoords.xyz;
                float3 N = normalize(i.normal);
                float3 L = normalize(_WorldSpaceLightPos0.xyz - P);
                float3 Kd = _Color.rgb;
                float3 lightColor = _LightColor0.rgb;
                float3 diffuseComponent = Kd * lightColor * max(dot(N, L), 0);
                
                float3 Ks = _SpecularColor.rgb;
                float3 V = normalize(_WorldSpaceCameraPos - P);
                float3 H = normalize(L + V);
                float3 specularComponent = Ks * lightColor * pow(max(dot(N, H), 0), _Shininess);
                
                
                float3 finalColor = ambientComponent + diffuseComponent + specularComponent;
                //return float4(finalColor, 1.0);
				if(i.position.x < 0.5f)
				{
					return float4(finalColor, 1.0) * tex2D(_MainTex, i.uv);
				}
				else
				{
					return float4(finalColor, 1.0) * tex2D(_MainTex2, i.uv);
				}
            }
            
            ENDCG
        }
    }
    FallBack "Diffuse"
}
