//
//  ViewController.swift
//  Codesscaner
//
//  Created by Jan Zelaznog on 13/05/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, CodeScanViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Crear el botón
        let button = UIButton(type: .system)
        // Configurar el botón
        button.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        button.setTitle("ESCANEA CóDIGO", for: .normal)
        button.center = self.view.center
        // Agregar el botón a la vista
        view.addSubview(button)
        // establecer el comportamiento
        button.addTarget(self, action: #selector(self.btnTouch(_:)), for: .touchUpInside)
    }

    @objc func btnTouch(_ sender: UIButton) {
        let permiso = AVCaptureDevice.authorizationStatus(for:.video)
        switch permiso {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { autorizado in
                DispatchQueue.main.async { // tenemos que regresar al thread principal para poder ejecutar cualquier modificacion a la UI
                    if autorizado { // si puedo usar la cámara para tomar video
                    
                    }
                    else { // El usuario no permitió el uso de la cámara
                        self.solicitarPermisos()
                    }
                }
            }
        case .restricted:
            solicitarPermisos()
        case .denied:
            solicitarPermisos()
        default: // si no se cumple ninguno de los anteriores, el estatus debe ser .authorized:
            print ("todo ok, iniciar la captura de video")
            let cdvc = CodeScanViewController()
            // asignamos como delegado esta misma clase, para poder recibir el código encontrado:
            cdvc.delegate = self
            self.present(cdvc, animated: true, completion: nil)
        }
    }
    
    func codeScanViewController(_ controller: CodeScanViewController, codeDetected: String) {
        controller.dismiss(animated: true, completion: nil)
        // TODO: hacer lo que sea necesario con el código detectado
        /*let ac = UIAlertController(title: "Éxito", message: "Se detectó el código: "+codeDetected, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        ac.addAction(okBtn)
        present(ac, animated: true, completion: nil)*/
        // if let laURL = URL(string:"tel:5556228517")  para hacer llamadas
        if let laURL = URL(string:codeDetected) {
            if UIApplication.shared.canOpenURL(laURL) {
                UIApplication.shared.open(laURL)
            }
        }
    }
    
    func solicitarPermisos() {
        let ac = UIAlertController(title: "Error", message: "La cámara es indispensable para que funcione el App. Desea autorizar esto ahora?", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "SI", style: .default) { comosea in
            if let urlDeSettings = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(urlDeSettings) {
                    UIApplication.shared.open(urlDeSettings, options:[:], completionHandler: nil)
                }
            }
        }
        let noBtn = UIAlertAction(title: "NO", style: .destructive, handler: nil)
        ac.addAction(okBtn)
        ac.addAction(noBtn)
        present(ac, animated: true, completion: nil)
    }
}

