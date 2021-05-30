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
	import spine.Color;
	import spine.Event;
	import spine.Skeleton;
	import spine.Slot;

	public class AlphaTimeline extends CurveTimeline1 implements SlotTimeline {
		static internal const ENTRIES : Number = 4;
		static internal const R : Number = 1;
		static internal const G : Number = 2;
		static internal const B : Number = 3;

		private var slotIndex : int;

		public function AlphaTimeline (frameCount : Number, bezierCount : Number, slotIndex : Number) {
			super(frameCount, bezierCount, [
				Property.alpha + "|" + slotIndex
			]);
			this.slotIndex = slotIndex;
		}

		public override function getFrameEntries() : int {
			return ENTRIES;
		}

		public function getSlotIndex() : int {
			return slotIndex;
		}

		public override function apply (skeleton : Skeleton, lastTime : Number, time : Number, events : Vector.<Event>, alpha : Number, blend : MixBlend, direction : MixDirection) : void {
			var slot : Slot = skeleton.slots[slotIndex];
			if (!slot.bone.active) return;

			var color : Color = slot.color;
			if (time < frames[0]) { // Time is before first frame.
				var setup : Color = slot.data.color;
				switch (blend) {
				case MixBlend.setup:
					color.a = setup.a;
					return;
				case MixBlend.first:
					color.a += (setup.a - color.a) * alpha;
				}
				return;
			}

			var a : Number = getCurveValue(time);
			if (alpha == 1)
				color.a = a;
			else {
				if (blend == MixBlend.setup) color.a = slot.data.color.a;
				color.a += (a - color.a) * alpha;
			}
		}
	}
}
