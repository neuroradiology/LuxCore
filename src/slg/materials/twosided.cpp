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

#include "slg/materials/twosided.h"

using namespace std;
using namespace luxrays;
using namespace slg;

//------------------------------------------------------------------------------
// Two-sided material
//------------------------------------------------------------------------------

TwoSidedMaterial::TwoSidedMaterial(const Texture *frontTransp, const Texture *backTransp,
		const Texture *emitted, const Texture *bump,
		const Material *frontMat, const Material *backMat) :
			Material(frontTransp, backTransp, emitted, bump),
			frontMat(frontMat), backMat(backMat) {
	Preprocess();
}

BSDFEvent TwoSidedMaterial::GetEventTypesImpl() const {
	return (frontMat->GetEventTypes() | backMat->GetEventTypes());
}

bool TwoSidedMaterial::IsLightSourceImpl() const {
	return (Material::IsLightSource() || frontMat->IsLightSource() || backMat->IsLightSource());
}

bool TwoSidedMaterial::HasBumpTexImpl() const { 
	return (Material::HasBumpTex() || frontMat->HasBumpTex() || backMat->HasBumpTex());
}

bool TwoSidedMaterial::IsDeltaImpl() const {
	return (frontMat->IsDelta() && backMat->IsDelta());
}

void TwoSidedMaterial::Preprocess() {
	// Cache values for performance with very large material node trees

	eventTypes = GetEventTypesImpl();

	if (frontMat->GetEventTypes() & GLOSSY) {
		if (backMat->GetEventTypes() & GLOSSY)
			glossiness = Min(frontMat->GetGlossiness(), backMat->GetGlossiness());
		else
			glossiness = frontMat->GetGlossiness();
	} else {
		if (backMat->GetEventTypes() & GLOSSY)
			glossiness = backMat->GetGlossiness();
		else
			glossiness = 0.f;
	}

	isLightSource = IsLightSourceImpl();
	hasBumpTex = HasBumpTexImpl();
	isDelta = IsDeltaImpl();
}

const Volume *TwoSidedMaterial::GetInteriorVolume(const HitPoint &hitPoint,
		const float passThroughEvent) const {
	if (interiorVolume)
		return interiorVolume;
	else {
		if (hitPoint.intoObject) {
			return frontMat->GetInteriorVolume(hitPoint, passThroughEvent);
		} else {
			return backMat->GetInteriorVolume(hitPoint, passThroughEvent);
		}
	}
}

const Volume *TwoSidedMaterial::GetExteriorVolume(const HitPoint &hitPoint,
		const float passThroughEvent) const {
	if (exteriorVolume)
		return exteriorVolume;
	else {
		if (hitPoint.intoObject) {
			return frontMat->GetExteriorVolume(hitPoint, passThroughEvent);
		} else {
			return backMat->GetExteriorVolume(hitPoint, passThroughEvent);
		}
	}
}

void TwoSidedMaterial::UpdateAvgPassThroughTransparency() {
	if (frontTransparencyTex || backTransparencyTex)
		Material::UpdateAvgPassThroughTransparency();
	else {
		avgPassThroughTransparency = frontMat->GetAvgPassThroughTransparency();
	}
}

Spectrum TwoSidedMaterial::GetPassThroughTransparency(const HitPoint &hitPoint,
		const Vector &localFixedDir, const float passThroughEvent,
		const bool backTracing) const {
	if (frontTransparencyTex || backTransparencyTex) {
		return Material::GetPassThroughTransparency(hitPoint, localFixedDir,
				passThroughEvent, backTracing);
	} else {
		if (hitPoint.intoObject) {
			return frontMat->GetPassThroughTransparency(hitPoint, localFixedDir,
					passThroughEvent, backTracing);
		} else {
			return backMat->GetPassThroughTransparency(hitPoint, localFixedDir,
					passThroughEvent, backTracing);
		}
	}
}

float TwoSidedMaterial::GetEmittedRadianceY(const float oneOverPrimitiveArea) const {
	if (emittedTex)
		return Material::GetEmittedRadianceY(oneOverPrimitiveArea);
	else
		return frontMat->GetEmittedRadianceY(oneOverPrimitiveArea);
}

Spectrum TwoSidedMaterial::GetEmittedRadiance(const HitPoint &hitPoint, const float oneOverPrimitiveArea) const {
	if (emittedTex)
		return Material::GetEmittedRadiance(hitPoint, oneOverPrimitiveArea);
	else {
		if (hitPoint.intoObject) {
			return frontMat->GetEmittedRadiance(hitPoint, oneOverPrimitiveArea);
		} else {
			return backMat->GetEmittedRadiance(hitPoint, oneOverPrimitiveArea);
		}
	}
}

Spectrum TwoSidedMaterial::Albedo(const HitPoint &hitPoint) const {
	if (hitPoint.intoObject) {
		return frontMat->Albedo(hitPoint);
	} else {
		return backMat->Albedo(hitPoint);
	}
}

Spectrum TwoSidedMaterial::Evaluate(const HitPoint &hitPoint,
		const Vector &localLightDir, const Vector &localEyeDir, BSDFEvent *event,
		float *directPdfW, float *reversePdfW) const {
	if (hitPoint.intoObject) {
		if (frontMat->HasBumpTex()) {
			const Frame frame(hitPoint.GetFrame());

			HitPoint bumpedHitPoint(hitPoint);
			frontMat->Bump(&bumpedHitPoint);
			const Frame bumpedFrame(bumpedHitPoint.GetFrame());
			const Vector bumpedLightDir = bumpedFrame.ToLocal(frame.ToWorld(localLightDir));
			const Vector bumpedEyeDir = bumpedFrame.ToLocal(frame.ToWorld(localEyeDir));
			return frontMat->Evaluate(bumpedHitPoint, bumpedLightDir, bumpedEyeDir, event, directPdfW, reversePdfW);
		}

		return frontMat->Evaluate(hitPoint, localLightDir, localEyeDir, event, directPdfW, reversePdfW);
	} else {
		if (backMat->HasBumpTex()) {
			const Frame frame(hitPoint.GetFrame());

			HitPoint bumpedHitPoint(hitPoint);
			backMat->Bump(&bumpedHitPoint);
			const Frame bumpedFrame(bumpedHitPoint.GetFrame());
			const Vector bumpedLightDir = bumpedFrame.ToLocal(frame.ToWorld(localLightDir));
			const Vector bumpedEyeDir = bumpedFrame.ToLocal(frame.ToWorld(localEyeDir));
			return backMat->Evaluate(bumpedHitPoint, bumpedLightDir, bumpedEyeDir, event, directPdfW, reversePdfW);
		}

		return backMat->Evaluate(hitPoint, localLightDir, localEyeDir, event, directPdfW, reversePdfW);
	}
}

Spectrum TwoSidedMaterial::Sample(const HitPoint &hitPoint,
		const Vector &localFixedDir, Vector *localSampledDir,
		const float u0, const float u1, const float passThroughEvent,
		float *pdfW, BSDFEvent *event, const BSDFEvent eventHint) const {
	if (hitPoint.intoObject) {
		if (frontMat->HasBumpTex()) {
			const Frame frame(hitPoint.GetFrame());

			HitPoint bumpedHitPoint(hitPoint);
			frontMat->Bump(&bumpedHitPoint);
			const Frame bumpedFrame(bumpedHitPoint.GetFrame());
			const Vector bumpedFixedDir = bumpedFrame.ToLocal(frame.ToWorld(localFixedDir));
			return frontMat->Sample(bumpedHitPoint, bumpedFixedDir, localSampledDir, u0, u1, passThroughEvent, pdfW, event, eventHint);
		}

		return frontMat->Sample(hitPoint, localFixedDir, localSampledDir, u0, u1, passThroughEvent, pdfW, event, eventHint);
	} else {
		if (backMat->HasBumpTex()) {
			const Frame frame(hitPoint.GetFrame());

			HitPoint bumpedHitPoint(hitPoint);
			backMat->Bump(&bumpedHitPoint);
			const Frame bumpedFrame(bumpedHitPoint.GetFrame());
			const Vector bumpedFixedDir = bumpedFrame.ToLocal(frame.ToWorld(localFixedDir));
			return backMat->Sample(bumpedHitPoint, bumpedFixedDir, localSampledDir, u0, u1, passThroughEvent, pdfW, event, eventHint);
		}

		return backMat->Sample(hitPoint, localFixedDir, localSampledDir, u0, u1, passThroughEvent, pdfW, event, eventHint);
	}
}

void TwoSidedMaterial::Pdf(const HitPoint &hitPoint,
		const Vector &localLightDir, const Vector &localEyeDir,
		float *directPdfW, float *reversePdfW) const {
	const Vector &localFixedDir = hitPoint.fromLight ? localLightDir : localEyeDir;
	const Vector &localSampledDir = hitPoint.fromLight ? localEyeDir : localLightDir;

	if (directPdfW) {
		if (localFixedDir.z < 0.f) {
			backMat->Pdf(hitPoint, localLightDir, localEyeDir, directPdfW, nullptr);
		} else {
			frontMat->Pdf(hitPoint, localLightDir, localEyeDir, directPdfW, nullptr);
		}
	}

	if (reversePdfW) {
		if (localSampledDir.z < 0.f) {
			backMat->Pdf(hitPoint, localLightDir, localEyeDir, nullptr, reversePdfW);
		} else {
			frontMat->Pdf(hitPoint, localLightDir, localEyeDir, nullptr, reversePdfW);
		}
	}
}

void TwoSidedMaterial::UpdateMaterialReferences(const Material *oldMat, const Material *newMat) {
	if (frontMat == oldMat)
		frontMat = newMat;

	if (backMat == oldMat)
		backMat = newMat;
	
	// Update volumes too
	Material::UpdateMaterialReferences(oldMat, newMat);
	
	Preprocess();
}

bool TwoSidedMaterial::IsReferencing(const Material *mat) const {
	return frontMat == mat || frontMat->IsReferencing(mat) ||
		backMat == mat || backMat->IsReferencing(mat);
}

void TwoSidedMaterial::AddReferencedMaterials(boost::unordered_set<const Material *> &referencedMats) const {
	Material::AddReferencedMaterials(referencedMats);

	referencedMats.insert(frontMat);
	frontMat->AddReferencedMaterials(referencedMats);

	referencedMats.insert(backMat);
	backMat->AddReferencedMaterials(referencedMats);
}

void TwoSidedMaterial::AddReferencedTextures(boost::unordered_set<const Texture *> &referencedTexs) const {
	Material::AddReferencedTextures(referencedTexs);

	frontMat->AddReferencedTextures(referencedTexs);
	backMat->AddReferencedTextures(referencedTexs);
}

void TwoSidedMaterial::UpdateTextureReferences(const Texture *oldTex, const Texture *newTex) {
	Material::UpdateTextureReferences(oldTex, newTex);

	Preprocess();
}

Properties TwoSidedMaterial::ToProperties(const ImageMapCache &imgMapCache, const bool useRealFileName) const  {
	Properties props;

	const string name = GetName();
	props.Set(Property("scene.materials." + name + ".type")("twosided"));
	props.Set(Property("scene.materials." + name + ".frontmaterial")(frontMat->GetName()));
	props.Set(Property("scene.materials." + name + ".backmaterial")(backMat->GetName()));
	props.Set(Material::ToProperties(imgMapCache, useRealFileName));

	return props;
}