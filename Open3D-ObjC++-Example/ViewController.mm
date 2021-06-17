//
//  ViewController.mm
//  Open3D-ObjC++-Example
//
//  Created by 안창범 on 2021/06/17.
//

#import "ViewController.h"
#import <open3d/Open3D.h>
#import <SceneKit/SceneKit.h>

using namespace open3d;

@interface ViewController ()

@property (strong, nonatomic) SCNScene *scene;

@property (weak, nonatomic) IBOutlet SCNView *sceneView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scene = [self makeScene];
    
    auto geometry = [self loadGeometry];
    auto node = [SCNNode nodeWithGeometry:geometry];
    NSLog(@"%@", node);
    
    [self.scene.rootNode addChildNode:node];
    
    auto front = simd_normalize(simd_make_float3(0.4257, -0.2125, -0.8795));
    auto lookAt = simd_make_float3(2.6172, 2.0475, 1.532);
    auto up = simd_make_float3(-0.0694, -0.9768, 0.2024);
    
    float distance = 3;
    auto eye = lookAt + front * distance;
    
    auto cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [self.scene.rootNode addChildNode: cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3FromFloat3(eye);
    [cameraNode lookAt:SCNVector3FromFloat3(lookAt)
                    up:SCNVector3FromFloat3(up)
            localFront:SCNVector3FromFloat3(front)];
    
    self.sceneView.scene = self.scene;
}

- (SCNGeometry *)loadGeometry {
    auto path = [[NSBundle mainBundle] pathForResource:@"fragment" ofType:@"ply"];
    geometry::PointCloud pcd;
    if (!io::ReadPointCloud(path.UTF8String, pcd)) {
        NSLog(@"failed to read %@", path);
        return nil;
    }
    NSLog(@"%lu", pcd.points_.size());
    
    unsigned long count = pcd.points_.size();
    SCNVector3 vertices[count];
    auto data = [NSMutableData dataWithLength:count * sizeof(int)];
    for (auto index = 0; index < count; ++index) {
        auto& v = pcd.points_[index];
        vertices[index] = SCNVector3Make((float) v(0), (float) v(1), (float) v(2));
        ((int *) data.bytes)[index] = index;
    }
    
    auto geometrySource = [SCNGeometrySource geometrySourceWithVertices:vertices count:count];
    auto geometryElement = [SCNGeometryElement geometryElementWithData:data primitiveType:SCNGeometryPrimitiveTypePoint primitiveCount:count bytesPerIndex:sizeof(int)];
    return [SCNGeometry geometryWithSources:@[geometrySource] elements:@[geometryElement]];
}

- (SCNScene *)makeScene {
    auto scene = [SCNScene scene];
    
    auto lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    auto ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = UIColor.darkGrayColor;
    [scene.rootNode addChildNode:ambientLightNode];

    return scene;
}

@end
