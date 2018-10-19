
import Foundation
import CoreImage

class GraySegmentFilter : CIFilter {
    
    private let kernel: CIColorKernel
    var inputImage: CIImage?
    var maskImage: CIImage?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override init() {
        let kernelStr = """
            kernel vec4 gray(__sample source, __sample mask) {
                float maskValue = mask.r;
                float gray = dot(source.rgb, vec3(0.299, 0.587, 0.114));
                if(maskValue == 0.0){
                   return vec4(vec3(gray),1.0);
                }
                return vec4(mix(vec3(gray),source.rgb,maskValue),1.0);
            }
        """
        let kernels = CIColorKernel.makeKernels(source:kernelStr)!
        kernel = kernels[0] as! CIColorKernel
        super.init()
    }
    
    override var outputImage: CIImage? {
        guard let inputImage = inputImage,let maskImage = maskImage else {return nil}
 
        let scale = inputImage.extent.width / maskImage.extent.width
        let suitableMaskImg = maskImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        return kernel.apply(extent: inputImage.extent, arguments:  [inputImage,suitableMaskImg])
    }
    
}
