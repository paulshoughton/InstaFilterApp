//
//  ContentView.swift
//  InstaFilterApp
//
//  Created by Paul Houghton on 05/11/2020.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 0.5
    @State private var filterScale = 0.5
    
    @State private var disableIntensity = false
    @State private var disableRadius = false
    @State private var disableScale = false
        
    @State private var showingFilterSheet = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State var currentFilterLabel: String = "Sepia Tone"
    let context = CIContext()
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
            }
        )
        
        let radius = Binding<Double>(
            get: {
                self.filterRadius
            },
            set: {
                self.filterRadius = $0
                self.applyProcessing()
            }
        )

        let scale = Binding<Double>(
            get: {
                self.filterScale
            },
            set: {
                self.filterScale = $0
                self.applyProcessing()
            }
        )
        
        return NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)
                    
                    // Old school work around for SwiftUI 1.0
//                    if image != nil {
//                        image?
//                            .resizable()
//                            .scaledToFit()
//                    } else {
//                        Text("Tap to select a picture")
//                            .foregroundColor(.white)
//                            .font(.headline)
//                    }
                    
                    // display image
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                    }
                    else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    self.showingImagePicker = true
                }
                HStack {
                    Text("Intensity")
                    Spacer()
                    Slider(value: intensity)
                        .frame(width: 250)
                        .disabled(disableIntensity)
                }
                .padding(.top)

                HStack {
                    Text("Radius")
                    Spacer()
                    Slider(value: radius)
                        .frame(width:250)
                        .disabled(disableRadius)
                }

                HStack {
                    Text("Scale")
                    Spacer()
                    Slider(value: scale)
                        .frame(width:250)
                        .disabled(disableScale)
                }
                .padding(.bottom)
                
                
                HStack {
                    Button(self.currentFilterLabel) {
                        self.showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        guard let processedImage = self.processedImage else {
                            self.alertTitle = "Save Error"
                            self.alertMessage = "No image specified."
                            self.showingAlert = true
                            return
                        }
                        
                        let imageSaver = ImageSaver()
                        imageSaver.successHandler = {
                            print("Success!")
                        }
                        imageSaver.errorHandler = {
                            print("Ooops: \($0.localizedDescription)")
                        }
                        
                        imageSaver.writeToPhotoAlbum(image: processedImage)
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("InstaFilter")
            .onAppear {
                updateSliderStatus()
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .actionSheet(isPresented: $showingFilterSheet) {
                ActionSheet(
                    title: Text("Select a filter"),
                    buttons: [
                        .default(Text("Crystallize")) {
                            self.setFilter(CIFilter.crystallize())
                            self.currentFilterLabel = "Crystallize"
                            updateSliderStatus()
                        },
                        .default(Text("Edges")) {
                            self.setFilter(CIFilter.edges())
                            self.currentFilterLabel = "Edges"
                            updateSliderStatus()
                        },
                        .default(Text("Gaussian Blur")) {
                            self.setFilter(CIFilter.gaussianBlur())
                            self.currentFilterLabel = "Gaussian Blur"
                            updateSliderStatus()
                        },
                        .default(Text("Pixellate")) {
                            self.setFilter(CIFilter.pixellate())
                            self.currentFilterLabel = "Pixellate"
                            updateSliderStatus()
                        },
                        .default(Text("Sepia Tone")) {
                            self.setFilter(CIFilter.sepiaTone())
                            self.currentFilterLabel = "Sepia Tone"
                            updateSliderStatus()
                        },
                        .default(Text("Unsharp Mask")) {
                            self.setFilter(CIFilter.unsharpMask())
                            self.currentFilterLabel = "Unsharp Mask"
                            updateSliderStatus()
                        },
                        .default(Text("Vignette")) {
                            self.setFilter(CIFilter.vignette())
                            self.currentFilterLabel = "Vignette"
                            updateSliderStatus()
                        },
                        .cancel()
                    ]
                )
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Okay")))
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
//        image = Image(uiImage: inputImage)
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func updateSliderStatus() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            disableIntensity = false
        }
        else {
            disableIntensity = true
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            disableRadius = false
        }
        else {
            disableRadius = true
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            disableScale = false
        }
        else {
            disableScale = true
        }
        
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius * 200, forKey:kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterScale * 10, forKey: kCIInputScaleKey)
        }
        
//        currentFilter.intensity = Float(filterIntensity)
//        currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
