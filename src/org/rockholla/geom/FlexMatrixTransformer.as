/*
 *	This is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *	 
 */
package org.rockholla.geom
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class FlexMatrixTransformer
	{
		public static function rotateAroundInternalPoint(m:Matrix, x:Number, y:Number, angleDegrees:Number):void
		{		
			var p:Point = m.transformPoint(new Point(x, y));
			rotateAroundExternalPoint(m, p.x, p.y, angleDegrees);
		}
		
		public static function rotateAroundExternalPoint(m:Matrix, x:Number, y:Number, angleDegrees:Number):void
		{
			m.translate(-x, -y);
			m.rotate(angleDegrees * (Math.PI/180));
			m.translate(x, y);
		}
	}

}