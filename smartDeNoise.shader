// SmartDeNoise shader for OBS Studio shaderfilter plugin
// originally for WebGL by Michele Morrone (https://github.com/BrutPitt/glslSmartDeNoise)
// Converted to OpenGL by Valentin Kirillov 15.01.2024

uniform float Sigma<
    string label = "Sigma";
    string widget_type = "slider";
    float minimum = 0.01;
    float maximum = 100.0;
    float step = 0.1;
> = 5.0;

uniform float KSigma<
    string label = "K Sigma";
    string widget_type = "slider";
    float minimum = 0.01;
    float maximum = 10.0;
    float step = 0.1;
> = 2.0;

uniform float Threshold<
    string label = "Threshold";
    string widget_type = "slider";
    float minimum = 0.01;
    float maximum = 1.0;
    float step = 0.01;
> = 0.1;

float4 mainImage(VertData v_in) : TARGET {
    float radius = round(KSigma * Sigma);
    float radQ = radius * radius;

    float invSigmaQx2 = 0.5 / (Sigma * Sigma);
    float invSigmaQx2PI = 1.0 / (sqrt(3.14159265359) * Sigma);

    float invThresholdSqx2 = 0.5 / (Threshold * Threshold);
    float invThresholdSqrt2PI = 1.0 / (sqrt(2.0 * 3.14159265359) * Threshold);

    float4 centrPx = image.Sample(textureSampler, v_in.uv);

    float zBuff = 0.0;
    float4 aBuff = float4(0.0, 0.0, 0.0, 0.0);
    int2 size = uv_size;

    for (float x = -radius; x <= radius; x++) {
        float pt = sqrt(radQ - x * x);
        for (float y = -pt; y <= pt; y++) {
            float2 d = float2(x, y) / float2(size.x, size.y);

            float blurFactor = exp(-dot(d, d) * invSigmaQx2) * invSigmaQx2PI;

            float4 walkPx = image.Sample(textureSampler, v_in.uv + d);

            float4 dC = walkPx - centrPx;
            float deltaFactor = exp(-dot(dC, dC) * invThresholdSqx2) * invThresholdSqrt2PI * blurFactor;

            zBuff += deltaFactor;
            aBuff += deltaFactor * walkPx;
        }
    }

    return aBuff / zBuff;
}
