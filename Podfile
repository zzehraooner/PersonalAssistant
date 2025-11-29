platform :ios, '17.0' # Projenizin minimum iOS sürümü

target 'PersonalAssistant' do
  use_frameworks!

pod 'FirebaseAnalytics'
pod 'FirebaseAuth'
pod 'FirebaseFirestore'
pod 'FirebaseFirestoreSwift'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    # Fix 1: BoringSSL-GRPC unsupported option '-G'
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          file.settings['COMPILER_FLAGS'] = file.settings['COMPILER_FLAGS'].gsub('-GCC_WARN_INHIBIT_ALL_WARNINGS', '').gsub('-G', '')
        end
      end
    end
  end

  # Fix 2: gRPC "template argument list" error (Fixes both gRPC-Core and gRPC-C++)
  # This command finds basic_seq.h in ANY Pods subfolder and patches it
  system("find Pods -name basic_seq.h -exec sed -i '' 's/Traits::template CallSeqFactory/Traits::template CallSeqFactory<>/g' {} +")
end
end
