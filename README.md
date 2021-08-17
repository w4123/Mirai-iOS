# Mirai-iOS
在iOS和iPadOS上运行Mirai（实验性）

### 设备要求
1. iOS 13及以上
2. 无需越狱

### 关于此项目
本项目中包含由溯洄为iOS修改编译的openjdk 17，修改版源码位于 https://github.com/w4123/jdk17

请注意此jdk移除了部分组件，主要是java.desktop模块，所以所有依赖于此模块的应用可能无法正常工作

为了使java能在非越狱iOS上正常运行，此jvm使用Zero解释器，无编译器，无动态代码生成，所以不需要JIT

缺点是Zero解释器会比标准HotSpot慢一些，但是对于机器人来说完全在可接受范围内

### 插件兼容性
1. 使用java.desktop模块功能的插件可能无法正常工作。对于对应的类会直接抛出ClassNotFoundException而不是HeadlessException
2. 使用JNI功能的插件需要为iOS单独编译Native部分，且由于iOS代码签名要求，你需要对Native代码进行对应签名后才能正常加载，否则会报错Code Signature Invalid
3. 仅包含jvm字节码且没有使用java.desktop模块的插件应该能正常兼容

### 其他
此项目目前处于测试阶段，对应功能仍不完整，欢迎Issue和PR

暂时不提供ipa下载，请自行编译测试
