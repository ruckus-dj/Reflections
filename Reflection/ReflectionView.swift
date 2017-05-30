//
// Created by Алексей Панкратов on 08.03.17.
// Copyright (c) 2017 ___FULLUSERNAME___. All rights reserved.
//

import UIKit

class ReflectionView: UIView{

    struct reflectionLine{
        var touch:UITouch;
        var points:[CGPoint];
        var color:CGColor;
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true;
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isMultipleTouchEnabled = true;
    }

    var lines:[reflectionLine] = [];

    override func draw(_ rect: CGRect) {
        super.draw(rect);
        let context = UIGraphicsGetCurrentContext()!;
        for line in lines{
            context.setStrokeColor(line.color);
            context.beginPath();
            context.move(to: center);
            for point in line.points {
                context.addLine(to: point);
            }
            context.strokePath();
        }
    }

    private func findBoundPoint(firstPoint: CGPoint, secondPoint: CGPoint, frame: CGRect) -> CGPoint{
        var x = CGFloat();
        var y = CGFloat();

        if(firstPoint.x > secondPoint.x){
            if(firstPoint.y > secondPoint.y){
                x = frame.maxX;
                y = (x - firstPoint.x) / (secondPoint.x - firstPoint.x) * (secondPoint.y - firstPoint.y) + firstPoint.y;
                if(y <= frame.maxY && y >= frame.minY){
                    return CGPoint(x: x, y: y);
                } else {
                    y = frame.maxY;
                    x = (y - firstPoint.y) / (secondPoint.y - firstPoint.y) * (secondPoint.x - firstPoint.x) + firstPoint.x;
                    return CGPoint(x: x, y: y);
                }
            } else {
                x = frame.maxX;
                y = (x - firstPoint.x) / (secondPoint.x - firstPoint.x) * (secondPoint.y - firstPoint.y) + firstPoint.y;
                if(y <= frame.maxY && y >= frame.minY){
                    return CGPoint(x: x, y: y);
                } else {
                    y = frame.minY;
                    x = (y - firstPoint.y) / (secondPoint.y - firstPoint.y) * (secondPoint.x - firstPoint.x) + firstPoint.x;
                    return CGPoint(x: x, y: y);
                }
            }
        } else {
            if(firstPoint.y > secondPoint.y){
                x = frame.minX;
                y = (x - firstPoint.x) / (secondPoint.x - firstPoint.x) * (secondPoint.y - firstPoint.y) + firstPoint.y;
                if(y <= frame.maxY && y >= frame.minY){
                    return CGPoint(x: x, y: y);
                } else {
                    y = frame.maxY;
                    x = (y - firstPoint.y) / (secondPoint.y - firstPoint.y) * (secondPoint.x - firstPoint.x) + firstPoint.x;
                    return CGPoint(x: x, y: y);
                }
            } else {
                x = frame.minX;
                y = (x - firstPoint.x) / (secondPoint.x - firstPoint.x) * (secondPoint.y - firstPoint.y) + firstPoint.y;
                if(y <= frame.maxY && y >= frame.minY){
                    return CGPoint(x: x, y: y);
                } else {
                    y = frame.minY;
                    x = (y - firstPoint.y) / (secondPoint.y - firstPoint.y) * (secondPoint.x - firstPoint.x) + firstPoint.x;
                    return CGPoint(x: x, y: y);
                }
            }
        }
    }

    private func findReflectionPoint(firstPoint: CGPoint, secondPoint: CGPoint, frame: CGRect) -> CGPoint{
        var k:CGFloat = 0;
        if(secondPoint.x - firstPoint.x != 0) {
            k = -(secondPoint.y - firstPoint.y) / (secondPoint.x - firstPoint.x);
        } else {
            if(secondPoint.y == frame.maxY){
                return CGPoint(x: secondPoint.x, y: frame.minY)
            } else {
                return CGPoint(x: secondPoint.x, y: frame.maxY)
            }
        }
        let b = secondPoint.y - k * secondPoint.x;
        if(k * frame.maxX + b >= frame.minY
                && k * frame.maxX + b <= frame.maxY
                && secondPoint.x != frame.maxX){
            return CGPoint(x: frame.maxX, y: k * frame.maxX + b);
        } else if(k * frame.minX + b >= frame.minY
                && k * frame.minX + b <= frame.maxY
                && secondPoint.x != frame.minX){
            return CGPoint(x: frame.minX, y: k * frame.minX + b);
        } else if((frame.minY - b)/k >= frame.minX
                && (frame.minY - b)/k <= frame.maxX
                && secondPoint.y != frame.minY){
            return CGPoint(x: (frame.minY - b)/k, y: frame.minY);
        } else {
            return CGPoint(x: (frame.maxY - b)/k, y: frame.maxY);
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event);
        for touch in touches{
            var line = reflectionLine(touch: touch, points: [],
                    color: UIColor(red: CGFloat(drand48()),
                            green: CGFloat(drand48()),
                            blue: CGFloat(drand48()),
                            alpha: 1.0).cgColor);
            line.points.append(findBoundPoint(firstPoint: touch.location(in: self), secondPoint: center, frame: frame));
            line.points.append(findReflectionPoint(firstPoint: center, secondPoint: line.points[0], frame: frame));
            line.points.append(findReflectionPoint(firstPoint: line.points[0], secondPoint: line.points[1], frame: frame));
            line.points.append(findReflectionPoint(firstPoint: line.points[1], secondPoint: line.points[2], frame: frame));
            lines.append(line);
        }
        setNeedsDisplay();
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        for touch in touches{
            for i in 0...lines.count {
                if (lines.count > i && lines[i].touch == touch){
                    lines[i].points.removeAll();
                    lines[i].points.append(findBoundPoint(firstPoint: touch.location(in: self), secondPoint: center, frame: frame));
                    lines[i].points.append(findReflectionPoint(firstPoint: center, secondPoint: lines[i].points[0], frame: frame));
                    lines[i].points.append(findReflectionPoint(firstPoint: lines[i].points[0], secondPoint: lines[i].points[1], frame: frame));
                    lines[i].points.append(findReflectionPoint(firstPoint: lines[i].points[1], secondPoint: lines[i].points[2], frame: frame));
                    break;
                }
            }
        }
        setNeedsDisplay();
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event);
        for touch in touches {
            for i in 0 ... lines.count {
                if(lines[i].touch == touch) {
                    lines.remove(at: i);
                    break;
                }
            }
        }
        setNeedsDisplay();
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event);
        for touch in touches {
            for i in 0 ... lines.count {
                if(lines[i].touch == touch) {
                    lines.remove(at: i);
                    break;
                }
            }
        }
        setNeedsDisplay();
    }

}