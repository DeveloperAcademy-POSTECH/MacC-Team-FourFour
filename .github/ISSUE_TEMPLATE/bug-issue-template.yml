name: Bug Template
description: 버그 발생 및 발견 시 제보하는 템플릿
title: "[Bug]: 버그 이슈 제목"
labels: ["bug"]

body:
  - type: input
    id: environment-os
    attributes:
      label: OS Version
      description: 버그가 발생한 OS
      placeholder: ex. iOS 15.3 watchOS 8.5
    validations:
      required: true
  - type: input
    id: environment-ios
    attributes:
      label: App Version
      description: 버그가 발생한 App Version
      placeholder: 1.0.3
    validations:
      required: true
  - type: input
    id: environment-xcode
    attributes:
      label: Xcode Version(Optional)
      description: 버그가 발생한 Xcode Version
      placeholder: "13.3"
    validations:
      required: false
  - type: dropdown
    id: target
    attributes:
      label: Target Device
      description: 버그가 발생된 앱이 실행된 곳
      options:
        - Simulator
        - Device
    validations:
      required: true
      
  - type: textarea
    id: what-bug
    attributes:
      label: Bug Report
      description: 어떤 버그인지 설명해주세요.
      placeholder: ex. 닉네임이 공백일 때, Submit이 가능한 버그
    validations:
      required: true
      
  - type: textarea
    id: where-bug
    attributes:
      label: Related Page
      description: 버그와 발생한 페이지를 알려주세요.
      placeholder: ex. MainView 
    validations:
      required: true
      
  - type: textarea
    id: bug-flow
    attributes:
      label: Bug Flow(Optional)
      description: 버그가 발생하게 된 Flow를 알려주세요.
      placeholder: ex. Tab bar의 Home을 200번 눌렀을 때, App이 종료된다.
    validations:
      required: false
      
