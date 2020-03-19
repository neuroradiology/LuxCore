#line 2 "texture_others_funcs.cl"

/***************************************************************************
 * Copyright 1998-2020 by authors (see AUTHORS.txt)                        *
 *                                                                         *
 *   This file is part of LuxCoreRender.                                   *
 *                                                                         *
 * Licensed under the Apache License, Version 2.0 (the "License");         *
 * you may not use this file except in compliance with the License.        *
 * You may obtain a copy of the License at                                 *
 *                                                                         *
 *     http://www.apache.org/licenses/LICENSE-2.0                          *
 *                                                                         *
 * Unless required by applicable law or agreed to in writing, software     *
 * distributed under the License is distributed on an "AS IS" BASIS,       *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.*
 * See the License for the specific language governing permissions and     *
 * limitations under the License.                                          *
 ***************************************************************************/

//------------------------------------------------------------------------------
// ConstFloat texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float ConstFloatTexture_ConstEvaluateFloat(__global const Texture* restrict tex) {
	return tex->constFloat.value;
}

OPENCL_FORCE_INLINE float3 ConstFloatTexture_ConstEvaluateSpectrum(__global const Texture* restrict tex) {
	return tex->constFloat.value;
}

// Note: ConstTexture_Bump() is defined in texture_bump_funcs.cl

//------------------------------------------------------------------------------
// ConstFloat3 texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float ConstFloat3Texture_ConstEvaluateFloat(__global const Texture* restrict tex) {
	return Spectrum_Y(VLOAD3F(tex->constFloat3.color.c));
}

OPENCL_FORCE_INLINE float3 ConstFloat3Texture_ConstEvaluateSpectrum(__global const Texture* restrict tex) {
	return VLOAD3F(tex->constFloat3.color.c);
}

// Note: ConstTexture_Bump() is defined in texture_bump_funcs.cl

//------------------------------------------------------------------------------
// ImageMap texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float ImageMapTexture_ConstEvaluateFloat(__global const Texture* restrict tex,
		__global const HitPoint *hitPoint
		TEXTURES_PARAM_DECL) {
	__global const ImageMap *imageMap = &imageMapDescs[tex->imageMapTex.imageMapIndex];

	const float2 mapUV = TextureMapping2D_Map(&tex->imageMapTex.mapping, hitPoint TEXTURES_PARAM);

	return tex->imageMapTex.gain * ImageMap_GetFloat(
			imageMap,
			mapUV.s0, mapUV.s1
			IMAGEMAPS_PARAM);
}

OPENCL_FORCE_INLINE float3 ImageMapTexture_ConstEvaluateSpectrum(__global const Texture* restrict tex,
		__global const HitPoint *hitPoint
		TEXTURES_PARAM_DECL) {
	__global const ImageMap *imageMap = &imageMapDescs[tex->imageMapTex.imageMapIndex];
	__global const float *pixels = ImageMap_GetPixelsAddress(
			imageMapBuff, imageMap->pageIndex, imageMap->pixelsIndex);

	const float2 mapUV = TextureMapping2D_Map(&tex->imageMapTex.mapping, hitPoint TEXTURES_PARAM);

	return tex->imageMapTex.gain * ImageMap_GetSpectrum(
			imageMap,
			mapUV.s0, mapUV.s1
			IMAGEMAPS_PARAM);
}

// Note: ImageMapTexture_Bump() is defined in texture_bump_funcs.cl

//------------------------------------------------------------------------------
// Scale texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float ScaleTexture_ConstEvaluateFloat(
		const float tex1, const float tex2) {
	return tex1 * tex2;
}

OPENCL_FORCE_INLINE float3 ScaleTexture_ConstEvaluateSpectrum(
		const float3 tex1, const float3 tex2) {
	return tex1 * tex2;
}

//------------------------------------------------------------------------------
// FresnelApproxN & FresnelApproxK texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float FresnelApproxNTexture_ConstEvaluateFloat(const float value) {
	return FresnelApproxN(value);
}

OPENCL_FORCE_INLINE float3 FresnelApproxNTexture_ConstEvaluateSpectrum(const float3 value) {
	return FresnelApproxN3(value);
}

OPENCL_FORCE_INLINE float FresnelApproxKTexture_ConstEvaluateFloat(const float value) {
	return FresnelApproxK(value);
}

OPENCL_FORCE_INLINE float3 FresnelApproxKTexture_ConstEvaluateSpectrum(const float3 value) {
	return FresnelApproxK3(value);
}

//------------------------------------------------------------------------------
// Mix texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float MixTexture_ConstEvaluateFloat(const float value1, const float value2,
		const float amt) {
	return mix(value1, value2, clamp(amt, 0.f, 1.f));
}

OPENCL_FORCE_INLINE float3 MixTexture_ConstEvaluateSpectrum(const float3 value1, const float3 value2,
		const float3 amt) {
	return mix(value1, value2, clamp(amt, 0.f, 1.f));
}

// Note: MixTexture_Bump() is defined in texture_bump_funcs.cl

//------------------------------------------------------------------------------
// Add texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float AddTexture_ConstEvaluateFloat(const float value1,
		const float value2) {
	return value1 + value2;
}

OPENCL_FORCE_INLINE float3 AddTexture_ConstEvaluateSpectrum(const float3 value1,
		const float3 value2) {
	return value1 + value2;
}

// Note: AddTexture_Bump() is defined in texture_bump_funcs.cl

//------------------------------------------------------------------------------
// Subtract texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float SubtractTexture_ConstEvaluateFloat(const float value1,
		const float value2) {
	return value1 - value2;
}

OPENCL_FORCE_INLINE float3 SubtractTexture_ConstEvaluateSpectrum(const float3 value1,
		const float3 value2) {
	return value1 - value2;
}

// Note: SubtractTexture_Bump() is defined in texture_bump_funcs.cl

//------------------------------------------------------------------------------
// HitPointColor texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float HitPointColorTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint,
		const uint dataIndex
		TEXTURES_PARAM_DECL) {
	return Spectrum_Y(HitPoint_GetColor(hitPoint, dataIndex EXTMESH_PARAM));
}

OPENCL_FORCE_INLINE float3 HitPointColorTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint,
		const uint dataIndex
		TEXTURES_PARAM_DECL) {
	return HitPoint_GetColor(hitPoint, dataIndex EXTMESH_PARAM);
}

//------------------------------------------------------------------------------
// HitPointAlpha texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float HitPointAlphaTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint,
		const uint dataIndex
		TEXTURES_PARAM_DECL) {
	return HitPoint_GetAlpha(hitPoint, dataIndex EXTMESH_PARAM);
}

OPENCL_FORCE_INLINE float3 HitPointAlphaTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint,
		const uint dataIndex
		TEXTURES_PARAM_DECL) {
	const float alpha = HitPoint_GetAlpha(hitPoint, dataIndex EXTMESH_PARAM);
	return (float3)(alpha, alpha, alpha);
}
//------------------------------------------------------------------------------
// HitPointGrey texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float HitPointGreyTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint,
		const uint dataIndex, const uint channel
		TEXTURES_PARAM_DECL) {
	const float3 col = HitPoint_GetColor(hitPoint, dataIndex EXTMESH_PARAM);

	switch (channel) {
		case 0:
			return col.s0;
		case 1:
			return col.s1;
		case 2:
			return col.s2;
		default:
			return Spectrum_Y(col);
	}
}

OPENCL_FORCE_INLINE float3 HitPointGreyTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint,
		const uint dataIndex, const uint channel
		TEXTURES_PARAM_DECL) {
	const float3 col = HitPoint_GetColor(hitPoint, dataIndex EXTMESH_PARAM);

	float v;
	switch (channel) {
		case 0:
			v = col.s0;
			break;
		case 1:
			v = col.s1;
			break;
		case 2:
			v = col.s2;
			break;
		default:
			v = Spectrum_Y(col);
			break;
	}

	return (float3)(v, v, v);
}

//------------------------------------------------------------------------------
// NormalMap texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float NormalMapTexture_ConstEvaluateFloat() {
    return 0.f;
}

OPENCL_FORCE_INLINE float3 NormalMapTexture_ConstEvaluateSpectrum() {
	return 0.f;
}

// Note: NormalMapTexture_Bump() is defined in texture_bump_funcs.cl

//------------------------------------------------------------------------------
// CheckerBoard 2D & 3D texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float CheckerBoard2DTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint,
		const float value1, const float value2, __global const TextureMapping2D *mapping
		TEXTURES_PARAM_DECL) {
	const float2 mapUV = TextureMapping2D_Map(mapping, hitPoint TEXTURES_PARAM);

	return ((Floor2Int(mapUV.s0) + Floor2Int(mapUV.s1)) % 2 == 0) ? value1 : value2;
}

OPENCL_FORCE_INLINE float3 CheckerBoard2DTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint,
		const float3 value1, const float3 value2, __global const TextureMapping2D *mapping
		TEXTURES_PARAM_DECL) {
	const float2 mapUV = TextureMapping2D_Map(mapping, hitPoint TEXTURES_PARAM);

	return ((Floor2Int(mapUV.s0) + Floor2Int(mapUV.s1)) % 2 == 0) ? value1 : value2;
}

OPENCL_FORCE_INLINE float CheckerBoard3DTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint,
		const float value1, const float value2, __global const TextureMapping3D *mapping
		TEXTURES_PARAM_DECL) {
	// The +DEFAULT_EPSILON_STATIC is there as workaround for planes placed exactly on 0.0
	const float3 mapP = TextureMapping3D_Map(mapping, hitPoint, NULL TEXTURES_PARAM) +  DEFAULT_EPSILON_STATIC;

	return ((Floor2Int(mapP.x) + Floor2Int(mapP.y) + Floor2Int(mapP.z)) % 2 == 0) ? value1 : value2;
}

OPENCL_FORCE_INLINE float3 CheckerBoard3DTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint,
		const float3 value1, const float3 value2, __global const TextureMapping3D *mapping
		TEXTURES_PARAM_DECL) {
	// The +DEFAULT_EPSILON_STATIC is there as workaround for planes placed exactly on 0.0
	const float3 mapP = TextureMapping3D_Map(mapping, hitPoint, NULL TEXTURES_PARAM) +  DEFAULT_EPSILON_STATIC;

	return ((Floor2Int(mapP.x) + Floor2Int(mapP.y) + Floor2Int(mapP.z)) % 2 == 0) ? value1 : value2;
}

//------------------------------------------------------------------------------
// Cloud texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float CloudTexture_CloudNoise(const float3 p, const float omegaValue, const uint octaves) {
	// Compute sum of octaves of noise
	float sum = 0.f, lambda = 1.f, o = 1.f;
	for (uint i = 0; i < octaves; ++i) {
		sum += o * Noise3(lambda * p);
		lambda *= 1.99f;
		o *= omegaValue;
	}
	return sum;
}

OPENCL_FORCE_INLINE float CloudTexture_NoiseMask(const float3 p, const float radius, const float omega) {
	return CloudTexture_CloudNoise(p / radius * 1.4f, omega, 1);
}

OPENCL_FORCE_INLINE float3 CloudTexture_Turbulence(const float3 p, const float noiseScale,
		const float noiseOffset, const float variability,
		const uint octaves, const float radius, const float omega,
		const float baseFlatness, const float3 sphereCentre) {
	float3 noiseCoords[3];
	const float baseFadeDistance = 1.f - baseFlatness;

	noiseCoords[0] = p / noiseScale;
	noiseCoords[1] = noiseCoords[0] + (float3)(noiseOffset, noiseOffset, noiseOffset);
	noiseCoords[2] = noiseCoords[1] + (float3)(noiseOffset, noiseOffset, noiseOffset);

	float noiseAmount = 1.f;

	if (variability < 1.f)
		noiseAmount = Lerp(variability, 1.f, CloudTexture_NoiseMask(p + (float3)(noiseOffset * 4.f, 0.f, 0.f), radius, omega));

	noiseAmount = clamp(noiseAmount, 0.f, 1.f);

	float3 turbulence;

	turbulence.x = CloudTexture_CloudNoise(noiseCoords[0], omega, octaves) - 0.15f;
	turbulence.y = CloudTexture_CloudNoise(noiseCoords[1], omega, octaves) - 0.15f;
	turbulence.z = -CloudTexture_CloudNoise(noiseCoords[2], omega, octaves);
	if (p.z < sphereCentre.z + baseFadeDistance)
		turbulence.z *= (p.z - sphereCentre.z) / (2.f * baseFadeDistance);

	turbulence *= noiseAmount;

	return turbulence;
}

OPENCL_FORCE_NOT_INLINE float CloudTexture_CloudShape(const float3 p, const float baseFadeDistance, const float3 sphereCentre, const uint numSpheres, const float radius) {
/*	if (numSpheres > 0) {
		if (SphereFunction(p, numSpheres))		//shows cumulus spheres
			return 1.f;
		else
			return 0.f;
	}
*/
	const float3 fromCentre = p - sphereCentre;

	float amount = 1.f - sqrt(fromCentre.x*fromCentre.x + fromCentre.y*fromCentre.y + fromCentre.z*fromCentre.z) / radius;
	if (amount < 0.f)
		return 0.f;

	// The base below the cloud's height fades out
	if (p.z < sphereCentre.z) {
		if (p.z < sphereCentre.z - radius * 0.4f)
			return 0.f;

		amount *= 1.f - cos((fromCentre.z + baseFadeDistance) /
			baseFadeDistance * M_PI_F * 0.5f);
	}
	return max(amount, 0.f);
}

/*
OPENCL_FORCE_INLINE bool CloudTexture_SphereFunction(const float3 p, uint numSpheres) const {
// Returns whether a point is inside one of the cumulus spheres
	for (uint i = 0; i < numSpheres; ++i) {
		if ((p - spheres[i].position).Length() < spheres[i].radius)
			return true;
	}
	return false;
}
*/

OPENCL_FORCE_NOT_INLINE float CloudTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint,
		const float radius, const uint numSpheres, const uint spheresize, const float sharpness,
		const float baseFadeDistance, const float baseFlatness, const float variability,
		const float omega, const float firstNoiseScale, const float noiseOffset, const float turbulenceAmount,
		const uint numOctaves, __global const TextureMapping3D *mapping
		TEXTURES_PARAM_DECL) {
	const float3 mapP = TextureMapping3D_Map(mapping, hitPoint, NULL TEXTURES_PARAM);
	const float3 sphereCentre = (float3)(.5f, .5f, 1.f / 3.f);
	const float amount = CloudTexture_CloudShape(mapP + turbulenceAmount * CloudTexture_Turbulence(mapP, firstNoiseScale, noiseOffset, variability, numOctaves, radius, omega, baseFlatness, sphereCentre), baseFadeDistance, sphereCentre, numSpheres, radius);
	const float finalValue = pow(amount * pow(10.f, .7f), sharpness);

	return min(finalValue, 1.f);
}

OPENCL_FORCE_NOT_INLINE float3 CloudTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint,
		const float radius, const uint numSpheres, const uint spheresize, const float sharpness,
		const float baseFadeDistance, const float baseFlatness, const float variability,
		const float omega, const float firstNoiseScale, const float noiseOffset, const float turbulenceAmount,
		const uint numOctaves, __global const TextureMapping3D *mapping
		TEXTURES_PARAM_DECL) {

	const float3 mapP = TextureMapping3D_Map(mapping, hitPoint, NULL TEXTURES_PARAM);
	const float3 sphereCentre = (float3)(.5f, .5f, 1.f / 3.f);
	const float amount = CloudTexture_CloudShape(mapP + turbulenceAmount * CloudTexture_Turbulence(mapP, firstNoiseScale, noiseOffset, variability, numOctaves, radius, omega, baseFlatness, sphereCentre), baseFadeDistance, sphereCentre, numSpheres, radius);
	const float finalValue = pow(amount * pow(10.f, .7f), sharpness);

	return min(finalValue, 1.f);
}

//------------------------------------------------------------------------------
// FBM texture
//------------------------------------------------------------------------------

OPENCL_FORCE_NOT_INLINE float FBMTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint,
	const float omega, const int octaves, __global const TextureMapping3D *mapping
	TEXTURES_PARAM_DECL) {
	const float3 mapP = TextureMapping3D_Map(mapping, hitPoint, NULL TEXTURES_PARAM);

	return FBm(mapP, omega, octaves);
}

OPENCL_FORCE_NOT_INLINE float3 FBMTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint,
	const float omega, const int octaves, __global const TextureMapping3D *mapping
	TEXTURES_PARAM_DECL) {
	const float3 mapP = TextureMapping3D_Map(mapping, hitPoint, NULL TEXTURES_PARAM);

	return FBm(mapP, omega, octaves);
}

//------------------------------------------------------------------------------
// Marble texture
//------------------------------------------------------------------------------

// Evaluate marble spline at _t_
__constant float MarbleTexture_c[9][3] = {
	{ .58f, .58f, .6f},
	{ .58f, .58f, .6f},
	{ .58f, .58f, .6f},
	{ .5f, .5f, .5f},
	{ .6f, .59f, .58f},
	{ .58f, .58f, .6f},
	{ .58f, .58f, .6f},
	{.2f, .2f, .33f},
	{ .58f, .58f, .6f}
};

OPENCL_FORCE_NOT_INLINE float3 MarbleTexture_Evaluate(__global const HitPoint *hitPoint, const float scale,
		const float omega, const int octaves, const float variation,
		__global const TextureMapping3D *mapping
		TEXTURES_PARAM_DECL) {
	const float3 P = scale * TextureMapping3D_Map(mapping, hitPoint, NULL TEXTURES_PARAM);

	float marble = P.y + variation * FBm(P, omega, octaves);
	float t = .5f + .5f * sin(marble);
#define NC  sizeof(MarbleTexture_c) / sizeof(MarbleTexture_c[0])
#define NSEG (NC-3)
	const int first = Floor2Int(t * NSEG);
	t = (t * NSEG - first);
#undef NC
#undef NSEG
#define ASSIGN_CF3(a) (float3)(a[0], a[1], a[2])
	const float3 c0 = ASSIGN_CF3(MarbleTexture_c[first]);
	const float3 c1 = ASSIGN_CF3(MarbleTexture_c[first + 1]);
	const float3 c2 = ASSIGN_CF3(MarbleTexture_c[first + 2]);
	const float3 c3 = ASSIGN_CF3(MarbleTexture_c[first + 3]);
#undef ASSIGN_CF3
	// Bezier spline evaluated with de Castilejau's algorithm
	float3 s0 = mix(c0, c1, t);
	float3 s1 = mix(c1, c2, t);
	float3 s2 = mix(c2, c3, t);
	s0 = mix(s0, s1, t);
	s1 = mix(s1, s2, t);
	// Extra scale of 1.5 to increase variation among colors
	return 1.5f * mix(s0, s1, t);
}

OPENCL_FORCE_NOT_INLINE float MarbleTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint,
		const float scale, const float omega, const int octaves, const float variation,
		__global const TextureMapping3D *mapping
		TEXTURES_PARAM_DECL) {
	return Spectrum_Y(MarbleTexture_Evaluate(hitPoint, scale, omega, octaves,
			variation, mapping
			TEXTURES_PARAM));
}

OPENCL_FORCE_NOT_INLINE float3 MarbleTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint,
		const float scale, const float omega, const int octaves, const float variation,
		__global const TextureMapping3D *mapping
		TEXTURES_PARAM_DECL) {
	return MarbleTexture_Evaluate(hitPoint, scale, omega, octaves,
			variation, mapping
			TEXTURES_PARAM);
}

//------------------------------------------------------------------------------
// Dots texture
//------------------------------------------------------------------------------

OPENCL_FORCE_NOT_INLINE bool DotsTexture_Evaluate(__global const HitPoint *hitPoint,
		__global const TextureMapping2D *mapping TEXTURES_PARAM_DECL) {
	const float2 uv = TextureMapping2D_Map(mapping, hitPoint TEXTURES_PARAM);

	const int sCell = Floor2Int(uv.s0 + .5f);
	const int tCell = Floor2Int(uv.s1 + .5f);
	// Return _insideDot_ result if point is inside dot
	if (Noise(sCell + .5f, tCell + .5f, .5f) > 0.f) {
		const float radius = .35f;
		const float maxShift = 0.5f - radius;
		const float sCenter = sCell + maxShift *
			Noise(sCell + 1.5f, tCell + 2.8f, .5f);
		const float tCenter = tCell + maxShift *
			Noise(sCell + 4.5f, tCell + 9.8f, .5f);
		const float ds = uv.s0 - sCenter, dt = uv.s1 - tCenter;
		if (ds * ds + dt * dt < radius * radius)
			return true;
	}

	return false;
}

OPENCL_FORCE_NOT_INLINE float DotsTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint,
		const float value1, const float value2, __global const TextureMapping2D *mapping
		TEXTURES_PARAM_DECL) {
	return DotsTexture_Evaluate(hitPoint, mapping TEXTURES_PARAM) ? value1 : value2;
}

OPENCL_FORCE_NOT_INLINE float3 DotsTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint,
		const float3 value1, const float3 value2, __global const TextureMapping2D *mapping
		TEXTURES_PARAM_DECL) {
	return DotsTexture_Evaluate(hitPoint, mapping TEXTURES_PARAM) ? value1 : value2;
}

//------------------------------------------------------------------------------
// Windy texture
//------------------------------------------------------------------------------

OPENCL_FORCE_NOT_INLINE float WindyTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint,
		__global const TextureMapping3D *mapping TEXTURES_PARAM_DECL) {
	const float3 mapP = TextureMapping3D_Map(mapping, hitPoint, NULL TEXTURES_PARAM);

	const float windStrength = FBm(.1f * mapP, .5f, 3);
	const float waveHeight = FBm(mapP, .5f, 6);

	return fabs(windStrength) * waveHeight;
}

OPENCL_FORCE_INLINE float3 WindyTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint,
		__global const TextureMapping3D *mapping TEXTURES_PARAM_DECL) {
	return WindyTexture_ConstEvaluateFloat(hitPoint, mapping TEXTURES_PARAM);
}

//------------------------------------------------------------------------------
// Wrinkled texture
//------------------------------------------------------------------------------

OPENCL_FORCE_NOT_INLINE float WrinkledTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint,
		const float omega, const int octaves,
		__global const TextureMapping3D *mapping TEXTURES_PARAM_DECL) {
	const float3 mapP = TextureMapping3D_Map(mapping, hitPoint, NULL TEXTURES_PARAM);

	return Turbulence(mapP, omega, octaves);
}

OPENCL_FORCE_INLINE float3 WrinkledTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint,
		const float omega, const int octaves,
		__global const TextureMapping3D *mapping
		TEXTURES_PARAM_DECL) {
	return WrinkledTexture_ConstEvaluateFloat(hitPoint, omega, octaves, mapping TEXTURES_PARAM);
}

//------------------------------------------------------------------------------
// UV texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float UVTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint,
		__global const TextureMapping2D *mapping TEXTURES_PARAM_DECL) {
	const float2 uv = TextureMapping2D_Map(mapping, hitPoint TEXTURES_PARAM);

	return Spectrum_Y((float3)(uv.s0 - Floor2Int(uv.s0), uv.s1 - Floor2Int(uv.s1), 0.f));
}

OPENCL_FORCE_INLINE float3 UVTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint,
		__global const TextureMapping2D *mapping TEXTURES_PARAM_DECL) {
	const float2 uv = TextureMapping2D_Map(mapping, hitPoint TEXTURES_PARAM);

	return (float3)(uv.s0 - Floor2Int(uv.s0), uv.s1 - Floor2Int(uv.s1), 0.f);
}

//------------------------------------------------------------------------------
// Band texture
//------------------------------------------------------------------------------

OPENCL_FORCE_NOT_INLINE float3 BandTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint,
		const InterpolationType interpType,
		const uint size, __global const float *offsets,
		__global const Spectrum *values, const float3 amt) {
	const float a = clamp(Spectrum_Y(amt), 0.f, 1.f);

	const uint last = size - 1;
	if (a < offsets[0])
		return VLOAD3F(values[0].c);
	else if (a >= offsets[last])
		return VLOAD3F(values[last].c);
	else {
		int p = 0;
		for (; p <= last; ++p) {
			if (a < offsets[p])
				break;
		}

		const float o1 = offsets[p - 1];
		const float o0 = offsets[p];
		const float factor = (a - o1) / (o0 - o1);

		if (interpType == INTERP_NONE)
			return VLOAD3F(values[p - 1].c);
		else if (interpType == INTERP_LINEAR) {
			const float3 p0 = VLOAD3F(values[p - 1].c);
			const float3 p1 = VLOAD3F(values[p].c);

			return Lerp3(factor, p0, p1);
		} else if (interpType == INTERP_CUBIC) {
			const float3 p0 = VLOAD3F(values[max(p - 2, 0)].c);
			const float3 p1 = VLOAD3F(values[p - 1].c);
			const float3 p2 = VLOAD3F(values[p].c);
			const float3 p3 = VLOAD3F(values[min(p + 1, (int)last)].c);

			return Cerp3(factor, p0, p1, p2, p3);
		} else
			return 0.f;
	}
}

OPENCL_FORCE_INLINE float BandTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint,
		const InterpolationType interpType,
		const uint size, __global const float *offsets,
		__global const Spectrum *values, const float amt) {
	return Spectrum_Y(BandTexture_ConstEvaluateSpectrum(hitPoint,
			interpType, size, offsets, values, amt));
}

//------------------------------------------------------------------------------
// Divide texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float DivideTexture_ConstEvaluateFloat(const float tex1, const float tex2) {
	if (tex2 == 0.f)
		return 0.f;
	return tex1 / tex2;
}

OPENCL_FORCE_INLINE float3 DivideTexture_ConstEvaluateSpectrum(const float3 tex1, const float3 tex2) {
	if (Spectrum_IsBlack(tex2))
		return BLACK;
	return tex1 / tex2;
}

//------------------------------------------------------------------------------
// Remap texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float RemapTexture_Remap(const float value,
		const float sourceMin, const float sourceMax,
		const float targetMin, const float targetMax) {
	if (sourceMin == sourceMax)
		return sourceMin;

	return (value - sourceMin)
	       * (targetMax - targetMin)
	       / (sourceMax - sourceMin)
	       + targetMin;
}

OPENCL_FORCE_INLINE float RemapTexture_ConstEvaluateFloat(
		const float value, const float sourceMin, const float sourceMax,
		const float targetMin, const float targetMax) {
	const float clampedValue = clamp(value, sourceMin, sourceMax);
	const float result = RemapTexture_Remap(clampedValue, sourceMin, sourceMax, targetMin, targetMax);
	return clamp(result, targetMin, targetMax);
}

OPENCL_FORCE_INLINE float3 RemapTexture_ConstEvaluateSpectrum(
		const float3 value, const float sourceMin, const float sourceMax,
		const float targetMin, const float targetMax) {
	const float3 clampedValue = clamp(value, sourceMin, sourceMax);
	float3 result;
	result.x = RemapTexture_Remap(clampedValue.x, sourceMin, sourceMax, targetMin, targetMax);
	result.y = RemapTexture_Remap(clampedValue.y, sourceMin, sourceMax, targetMin, targetMax);
	result.z = RemapTexture_Remap(clampedValue.z, sourceMin, sourceMax, targetMin, targetMax);
	return clamp(result, targetMin, targetMax);
}

//------------------------------------------------------------------------------
// ObjectID texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float ObjectIDTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint) {
	return (float)hitPoint->objectID;
}

OPENCL_FORCE_INLINE float3 ObjectIDTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint) {
	const uint id = hitPoint->objectID;
	return (float3)(id, id, id);
}

//------------------------------------------------------------------------------
// ObjectIDColor texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float3 ObjectIDColorTexture_IDToSpectrum(const uint id) {
	return (float3)((id & 0x0000ffu) * ( 1.f / 255.f),
	                ((id & 0x00ff00u) >> 8) * ( 1.f / 255.f),
	                ((id & 0xff0000u) >> 16) * ( 1.f / 255.f));
}

OPENCL_FORCE_INLINE float ObjectIDColorTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint) {
	return Spectrum_Y(ObjectIDColorTexture_IDToSpectrum(hitPoint->objectID));
}

OPENCL_FORCE_INLINE float3 ObjectIDColorTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint) {
	return ObjectIDColorTexture_IDToSpectrum(hitPoint->objectID);
}

//------------------------------------------------------------------------------
// ObjectIDNormalized texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float ObjectIDNormalizedTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint) {
	return ((float)hitPoint->objectID) * (1.f / 0xffffffffu);
}

OPENCL_FORCE_INLINE float3 ObjectIDNormalizedTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint) {
	const float normalized = ((float)hitPoint->objectID) * (1.f / 0xffffffffu);
	return (float3)(normalized, normalized, normalized);
}

//------------------------------------------------------------------------------
// DotProduct texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float DotProductTexture_ConstEvaluateFloat(const float3 tex1,
		const float3 tex2) {
	return dot(tex1, tex2);
}

OPENCL_FORCE_INLINE float3 DotProductTexture_ConstEvaluateSpectrum(const float3 tex1,
		const float3 tex2) {
	const float result = dot(tex1, tex2);
	return (float3)(result, result, result);
}

//------------------------------------------------------------------------------
// Greater Than texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float GreaterThanTexture_ConstEvaluateFloat(const float tex1,
		const float tex2) {
	return (tex1 > tex2) ? 1.f : 0.f;
}

OPENCL_FORCE_INLINE float3 GreaterThanTexture_ConstEvaluateSpectrum(const float tex1,
		const float tex2) {
	const float result = (tex1 > tex2) ? 1.f : 0.f;
	return (float3)(result, result, result);
}

//------------------------------------------------------------------------------
// Less Than texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float LessThanTexture_ConstEvaluateFloat(const float tex1,
		const float tex2) {
	return (tex1 < tex2) ? 1.f : 0.f;
}

OPENCL_FORCE_INLINE float3 LessThanTexture_ConstEvaluateSpectrum(const float tex1,
		const float tex2) {
	const float result = (tex1 < tex2) ? 1.f : 0.f;
	return (float3)(result, result, result);
}

//------------------------------------------------------------------------------
// Power texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float PowerTexture_SafePow(const float base, const float exponent) {
	if (base < 0.f && exponent != ((int)exponent))
		return 0.f;
	return pow(base, exponent);
}

OPENCL_FORCE_INLINE float PowerTexture_ConstEvaluateFloat(const float base,
		const float exponent) {
	return PowerTexture_SafePow(base, exponent);
}

OPENCL_FORCE_INLINE float3 PowerTexture_ConstEvaluateSpectrum(const float base,
		const float exponent) {
	const float result = PowerTexture_SafePow(base, exponent);
	return (float3)(result, result, result);
}

//------------------------------------------------------------------------------
// Shading Normal texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float ShadingNormalTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint) {
	// This method doesn't really make sense for a vector - just return the first element
	return hitPoint->shadeN.x;
}

OPENCL_FORCE_INLINE float3 ShadingNormalTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint) {
	return (float3)(hitPoint->shadeN.x, hitPoint->shadeN.y, hitPoint->shadeN.z);
}

//------------------------------------------------------------------------------
// Position texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float PositionTexture_ConstEvaluateFloat(__global const HitPoint *hitPoint) {
	// This method doesn't really make sense for a vector - just return the first element
	return hitPoint->p.x;
}

OPENCL_FORCE_INLINE float3 PositionTexture_ConstEvaluateSpectrum(__global const HitPoint *hitPoint) {
	return (float3)(hitPoint->p.x, hitPoint->p.y, hitPoint->p.z);
}

//------------------------------------------------------------------------------
// Split float3 texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float SplitFloat3Texture_ConstEvaluateFloat(const float3 tex,
		const uint channel) {
	switch (channel) {
		case 0:
			return tex.x;
		case 1:
			return tex.y;
		case 2:
			return tex.z;
		default:
			return 0.f;
	}
}

OPENCL_FORCE_INLINE float3 SplitFloat3Texture_ConstEvaluateSpectrum(const float3 tex,
		const uint channel) {
	float result;
	switch (channel) {
		case 0:
			result = tex.x;
			break;
		case 1:
			result = tex.y;
			break;
		case 2:
			result = tex.z;
			break;
		default:
			result = 0.f;
			break;
	}

	return (float3) (result, result, result);
}

//------------------------------------------------------------------------------
// Make float3 texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float MakeFloat3Texture_ConstEvaluateFloat(const float tex1,
		const float tex2, const float tex3) {
	return Spectrum_Y((float3)(tex1, tex2, tex3));
}

OPENCL_FORCE_INLINE float3 MakeFloat3Texture_ConstEvaluateSpectrum(const float tex1,
		const float tex2, const float tex3) {
	return (float3)(tex1, tex2, tex3);
}

//------------------------------------------------------------------------------
// Rounding texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float RoundingTexture_ConstEvaluateFloat(const float tex1, const float tex2) {
    if(tex1 == tex2 || tex2 == 0) {
        return tex1;
    } else {
        const float innerBound = tex2 * (int) (tex1 / tex2);
        const float outerBound = (tex1 < 0 ? innerBound - tex2 : innerBound + tex2);
        return fabs(outerBound - tex1) < fabs(innerBound - tex1) ?
            outerBound : innerBound;
    }
}

OPENCL_FORCE_INLINE float3 RoundingTexture_ConstEvaluateSpectrum(const float tex1, const float tex2) {
    const float result = RoundingTexture_ConstEvaluateFloat(tex1, tex2);
    return (float3)(result, result, result);
}

//------------------------------------------------------------------------------
// Modulo texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float ModuloTexture_ConstEvaluateFloat(const float tex1, const float tex2) {
    if(tex2 == 0) {
        return 0.f;
    }

    return fmod(tex1, tex2);
}

OPENCL_FORCE_INLINE float3 ModuloTexture_ConstEvaluateSpectrum(const float tex1, const float tex2) {
    const float result = ModuloTexture_ConstEvaluateFloat(tex1, tex2);
    return (float3)(result, result, result);
}

//------------------------------------------------------------------------------
// Brightness/Contrast texture
//------------------------------------------------------------------------------

OPENCL_FORCE_INLINE float BrightContrastTexture_ConstEvaluateFloat(const float tex,
		const float brightnessTex, const float contrastTex) {
	const float a = 1.f + contrastTex;
	const float b = brightnessTex - contrastTex * 0.5f;

	return clamp(tex * a + b, 0.f, INFINITY);
}

OPENCL_FORCE_INLINE float3 BrightContrastTexture_ConstEvaluateSpectrum(const float3 tex,
		const float brightnessTex, const float contrastTex) {
    const float a = 1.f + contrastTex;
	const float b = brightnessTex - contrastTex * 0.5f;

	return clamp(tex * a + b, 0.f, INFINITY);
}
