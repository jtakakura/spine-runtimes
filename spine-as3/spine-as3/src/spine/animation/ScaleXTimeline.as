/******************************************************************************
 * Spine Runtimes License Agreement
 * Last updated January 1, 2020. Replaces all prior versions.
 *
 * Copyright (c) 2013-2020, Esoteric Software LLC
 *
 * Integration of the Spine Runtimes into software or otherwise creating
 * derivative works of the Spine Runtimes is permitted under the terms and
 * conditions of Section 2 of the Spine Editor License Agreement:
 * http://esotericsoftware.com/spine-editor-license
 *
 * Otherwise, it is permitted to integrate the Spine Runtimes into software
 * or otherwise create derivative works of the Spine Runtimes (collectively,
 * "Products"), provided that each user of the Products must obtain their own
 * Spine Editor license and redistribution of the Products in any form must
 * include this license and copyright notice.
 *
 * THE SPINE RUNTIMES ARE PROVIDED BY ESOTERIC SOFTWARE LLC "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL ESOTERIC SOFTWARE LLC BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES,
 * BUSINESS INTERRUPTION, OR LOSS OF USE, DATA, OR PROFITS) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THE SPINE RUNTIMES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

package spine.animation {
	import spine.Bone;
	import spine.Event;
	import spine.Skeleton;
	import spine.MathUtils;

	public class ScaleXTimeline extends CurveTimeline1 implements BoneTimeline {
		private var boneIndex : int;

		public function ScaleXTimeline(frameCount : int, bezierCount : int, boneIndex : int) {
			super(frameCount, bezierCount, [
				Property.scaleX + "|" + boneIndex
			]);
			this.boneIndex = boneIndex;
		}

		public function getBoneIndex() : int {
			return boneIndex;
		}

		public override function apply (skeleton : Skeleton, lastTime : Number, time : Number, events : Vector.<Event>, alpha : Number, blend : MixBlend, direction : MixDirection) : void {
			var bone : Bone = skeleton.bones[boneIndex];
			if (!bone.active) return;

			var frames : Vector.<Number> = this.frames;
			if (time < frames[0]) {
				switch (blend) {
				case MixBlend.setup:
					bone.scaleX = bone.data.scaleX;
					return;
				case MixBlend.first:
					bone.scaleX += (bone.data.scaleX - bone.scaleX) * alpha;
				}
				return;
			}

			var x : Number = getCurveValue(time) * bone.data.scaleX;
			if (alpha == 1) {
				if (blend == MixBlend.add)
					bone.scaleX += x - bone.data.scaleX;
				else
					bone.scaleX = x;
			} else {
				// Mixing out uses sign of setup or current pose, else use sign of key.
				var bx : Number = 0;
				if (direction == MixDirection.mixOut) {
					switch (blend) {
					case MixBlend.setup:
						bx = bone.data.scaleX;
						bone.scaleX = bx + (Math.abs(x) * MathUtils.signum(bx) - bx) * alpha;
						break;
					case MixBlend.first:
					case MixBlend.replace:
						bx = bone.scaleX;
						bone.scaleX = bx + (Math.abs(x) * MathUtils.signum(bx) - bx) * alpha;
						break;
					case MixBlend.add:
						bx = bone.scaleX;
						bone.scaleX = bx + (Math.abs(x) * MathUtils.signum(bx) - bone.data.scaleX) * alpha;
					}
				} else {
					switch (blend) {
					case MixBlend.setup:
						bx = Math.abs(bone.data.scaleX) * MathUtils.signum(x);
						bone.scaleX = bx + (x - bx) * alpha;
						break;
					case MixBlend.first:
					case MixBlend.replace:
						bx = Math.abs(bone.scaleX) * MathUtils.signum(x);
						bone.scaleX = bx + (x - bx) * alpha;
						break;
					case MixBlend.add:
						bx = MathUtils.signum(x);
						bone.scaleX = Math.abs(bone.scaleX) * bx + (x - Math.abs(bone.data.scaleX) * bx) * alpha;
					}
				}
			}
		}
	}
}
