//
//  CodeScanViewController.swift
//  Codesscaner
//
//  Created by Jan Zelaznog on 14/05/21.
//

import UIKit
import AVFoundation

// Declarar el protocolo, para implementar el patrón de delegación
protocol CodeScanViewControllerDelegate {
    // todos los métodos que se especifiquen en el protocolo son requeridos, a menos que se marquen asi:
    // @objc optional
    func codeScanViewController(_ controller: CodeScanViewController, codeDetected:String)
}


class CodeScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captura:AVCaptureSession!   // indica que la variable NO es opcional
    var capaDePreview: AVCaptureVideoPreviewLayer!
    
    // especificamos la propiedad "delegate" para poder conectar con el objeto que implemente el protocolo
    var delegate:CodeScanViewControllerDelegate?
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // del arreglo de metadatos encontrados obtengo el primero. es 99% seguro que todo el arreglo sean repeticiones del mismo objeto
        if let objetoMetadata = metadataObjects.first {
            // intentamos obtener la representación del objeto que encontró
            guard let objetoReconocido = objetoMetadata as? AVMetadataMachineReadableCodeObject else { return }
            // intentamos obtener el valor como texto, de la representación del objeto que encontró
            guard let valorComoString = objetoReconocido.stringValue else { return }
            // Para que el telefono haga una pequeña vibración cuando encuentre el código
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            // que hacemos con el valor encontrado?
            // IMPLEMENTAR PATRON DE DELEGACION
            if delegate != nil {
                // Envío el codigo encontrado al delegado
                delegate?.codeScanViewController(self, codeDetected: valorComoString)
                captura.stopRunning()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Creamos una sesión de captura de video
        captura = AVCaptureSession()
        // intentamos obtener el dispositivo de video predeterminado
        guard let dispositivoDeCaptura = AVCaptureDevice.default(for:.video) else {
            // avisar del error al usuario:
            self.muestraError()
            return
        }
        do {
            // creamos una entrada de video, a partir del dispositivo predeterminado
            let entradaDeVideo = try AVCaptureDeviceInput(device: dispositivoDeCaptura)
            // conectamos la entrada de video a la sesión de captura
            if captura.canAddInput(entradaDeVideo) {
                captura.addInput(entradaDeVideo)
            }
            // creamos el objeto para manejar los metadatos de las imágenes
            let metadatos = AVCaptureMetadataOutput()
            // agregamos los metadatos como "salida" de la sesión de captura
            // SE DEBE CONECTAR A LA SESION EN PRIMER LUGAR, PARA QUE ENTONCES SE PUEDAN IDENTIFICAR LOS METADATOS RECONOCIBLES
            if captura.canAddOutput(metadatos) {
                captura.addOutput(metadatos)
                // especificamos que tipo de objetos (metadatos) queremos que reconozca
                metadatos.metadataObjectTypes = [.ean8, .ean13, .qr, .pdf417]
                // especificamos que cuando encuentre un metadato, a que objeto de debe avisar
                metadatos.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            }
            
            // configuramos la capa de preview para que el usuario pueda ver lo que "ve" la cámara
            capaDePreview = AVCaptureVideoPreviewLayer(session: captura)
            capaDePreview.frame = view.layer.bounds  // bounds también es un objeto de la struc CGRect al igual que frame, la diferencia es que bounds es relativo a la orientación
            view.layer.addSublayer(capaDePreview)
            captura.startRunning()
        }
        catch {
            print (error.localizedDescription)
            muestraError()
        }
    }
    
    func muestraError() {
        let ac = UIAlertController(title: "Error", message: "La cámara no funciona", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "SI", style: .default, handler:{ ac in
            self.dismiss(animated:true, completion:nil)
        })
        ac.addAction(okBtn)
        present(ac, animated: true, completion: nil)
    }
}
