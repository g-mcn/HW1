//RD code based on Shiffman's Processing video: https://youtu.be/BV9ny785UNc

Shader "Custom/RenderToTexture_RD"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {} 
    }
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
            
            uniform float4 _MainTex_TexelSize;
           
            
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv: TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv: TEXCOORD0;
			};
   
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
            
           
            sampler2D_float _MainTex;
            
			fixed4 frag(v2f i) : SV_Target
			{
                
                float dA = 1.0;
                float dB = 0.5;
                float feed = 0.055;
                float k = 0.062;
            
                float2 texel = float2(
                    _MainTex_TexelSize.x, 
                    _MainTex_TexelSize.y 
                );
                
                float cx = i.uv.x;
                float cy = i.uv.y;
                
                float4 C = tex2D( _MainTex, float2( cx, cy ));   
                
                float up = i.uv.y + texel.y * 1;
                float down = i.uv.y + texel.y * -1;
                float right = i.uv.x + texel.x * 1;
                float left = i.uv.x + texel.x * -1;
                
                float4 arr[8];
                
                arr[0] = tex2D(  _MainTex, float2( cx   , up ));   //N
                arr[1] = tex2D(  _MainTex, float2( right, up ));   //NE
                arr[2] = tex2D(  _MainTex, float2( right, cy ));   //E
                arr[3] = tex2D(  _MainTex, float2( right, down )); //SE
                arr[4] = tex2D(  _MainTex, float2( cx   , down )); //S
                arr[5] = tex2D(  _MainTex, float2( left , down )); //SW
                arr[6] = tex2D(  _MainTex, float2( left , cy ));   //W
                arr[7] = tex2D(  _MainTex, float2( left , up ));   //NW
                
                
                //Laplace A
                float sumA = 0.0;
                sumA += C.r * -1.0;
                sumA += arr[6].r * 0.2; //W
                sumA += arr[2].r * 0.2; //E
                sumA += arr[0].r * 0.2; //N
                sumA += arr[4].r * 0.2; //S
                sumA += arr[5].r * 0.05; //SW
                sumA += arr[3].r * 0.05; //SE
                sumA += arr[1].r * 0.05; //NE
                sumA += arr[7].r * 0.05; //NW
                
                //Laplace A
                float sumB = 0.0;
                sumB += C.g * -1.0;
                sumB += arr[6].g * 0.2; //W
                sumB += arr[2].g * 0.2; //E
                sumB += arr[0].g * 0.2; //N
                sumB += arr[4].g * 0.2; //S
                sumB += arr[5].g * 0.05; //SW
                sumB += arr[3].g * 0.05; //SE
                sumB += arr[1].g * 0.05; //NE
                sumB += arr[7].g * 0.05; //NW
                
                float nextR =  C.r +
                    (dA * sumA) -
                    (C.r * C.g * C.g) +
                    (feed * (1 - C.r));
                    
                float nextG =  C.g +
                    (dB * sumB) +
                    (C.r * C.g * C.g) -
                    ((k + feed) * C.g);
                    
                //nextR = C.r + 0.00001;  //tmp
                nextR = clamp(nextR, 0.0, 1.0);
                nextG = clamp(nextG, 0.0, 1.0);
                
               return float4(nextR, nextG, 0.0, 0.0);
               //return float4(1.0, 0.5, 0.5, 1.0);
               //return float4(nextR, C.g, C.b, 1.0);
               
               
               /*
               if (cx > 0.5) {
                return float4(1.0,0.0,0.0,1.0);
               } else {
                 return float4(0.0,1.0,0.0,1.0);
               }
               */
                
            }

			ENDCG
		}

	}
	FallBack "Diffuse"
}