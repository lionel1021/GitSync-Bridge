# 🤝 贡献指南 | Contributing Guide

> 感谢您对GitSync-Bridge项目的关注！我们欢迎所有形式的贡献。

## 🎯 **贡献方式**

### 🐛 **报告问题**
- 在GitHub Issues中描述问题
- 提供详细的错误信息和重现步骤
- 包含系统环境和配置信息

### 💡 **功能建议**
- 在GitHub Discussions中提出想法
- 详细描述功能的使用场景
- 提供具体的实现建议

### 🔧 **代码贡献**
- Fork项目到你的GitHub账户
- 创建功能分支进行开发
- 提交Pull Request

### 📚 **文档改进**
- 完善README和使用指南
- 添加新的使用案例
- 翻译文档到其他语言

## 🚀 **开发指南**

### 环境要求
- Git 2.20+
- Node.js 16+ (如果需要测试脚本)
- 基本的Shell脚本知识

### 项目结构
```
GitSync-Bridge/
├── .github/workflows/     # GitHub Actions配置
├── scripts/              # 自动化脚本
├── docs/                 # 文档
├── examples/             # 使用示例
├── templates/            # 配置模板
└── README.md             # 项目说明
```

### 开发流程
1. **Fork项目**
   ```bash
   git clone https://github.com/your-username/GitSync-Bridge.git
   cd GitSync-Bridge
   ```

2. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **开发和测试**
   ```bash
   # 修改代码
   # 测试功能
   ./scripts/test-sync.sh
   ```

4. **提交更改**
   ```bash
   git add .
   git commit -m "✨ 添加新功能: 功能描述"
   git push origin feature/your-feature-name
   ```

5. **创建Pull Request**
   - 详细描述更改内容
   - 添加相关的测试结果
   - 确保通过所有检查

## 📝 **代码规范**

### 提交信息格式
使用emoji和简洁的描述：
```
✨ feat: 添加新功能
🐛 fix: 修复问题
📚 docs: 更新文档
🎨 style: 代码格式调整
♻️ refactor: 重构代码
⚡ perf: 性能优化
✅ test: 添加测试
🔧 chore: 构建配置更改
```

### YAML文件规范
```yaml
# 使用统一的缩进 (2空格)
name: 🔄 Workflow Name

on:
  push:
    branches: [ main ]

jobs:
  job-name:
    runs-on: ubuntu-latest
    steps:
    - name: 📥 Step description
      uses: actions/checkout@v4
```

### 脚本规范
```bash
#!/bin/bash
# 脚本描述

set -e  # 遇到错误立即退出

# 使用颜色和emoji增强可读性
GREEN='\033[0;32m'
NC='\033[0m'
echo -e "${GREEN}✅ 操作成功${NC}"
```

## 🧪 **测试指南**

### 功能测试
在提交代码前，请确保：
- [ ] 基本同步功能正常
- [ ] 错误处理机制有效
- [ ] 文档与代码保持一致

### 测试脚本
```bash
# 运行基础测试
./scripts/test-sync.sh

# 测试不同配置
./scripts/test-config.sh personal
./scripts/test-config.sh enterprise
```

### 手动测试检查清单
- [ ] GitHub → Gitee 同步
- [ ] Gitee → GitHub 同步
- [ ] 冲突处理
- [ ] 错误恢复
- [ ] 日志输出

## 📋 **Issue模板**

### Bug报告
```markdown
## 🐛 Bug描述
简洁描述遇到的问题

## 🔄 重现步骤
1. 第一步
2. 第二步
3. 看到错误

## 💻 环境信息
- OS: [e.g. macOS 12.0]
- Git版本: [e.g. 2.34.0]
- 项目配置: [基础/高级/企业]

## 📊 预期行为
描述你期望发生的情况

## 📷 截图
如果适用，添加截图来解释问题

## 📝 额外信息
添加任何其他有助于解决问题的信息
```

### 功能请求
```markdown
## 🚀 功能描述
清晰描述你想要的功能

## 🎯 使用场景
解释为什么需要这个功能

## 💡 建议实现
如果有想法，描述可能的实现方式

## 📚 参考资料
相关的文档、链接或示例
```

## 🏆 **贡献者认可**

### 贡献类型
- 🐛 **Bug修复**
- ✨ **功能开发**
- 📚 **文档编写**
- 🌍 **国际化翻译**
- 🎨 **界面设计**
- 💡 **想法建议**

### 认可方式
- 在README中展示贡献者头像
- 在Release Notes中感谢贡献
- 颁发"贡献者"徽章
- 邀请加入维护团队

## 🌏 **社区行为准则**

### 我们的承诺
我们致力于为每个人提供友好、安全和包容的环境。

### 期望行为
- 使用友善和包容的语言
- 尊重不同的观点和经验
- 优雅地接受建设性批评
- 专注于对社区最有利的事情

### 不当行为
- 使用性别化语言或意象
- 人身攻击或政治攻击
- 公开或私下骚扰
- 未经明确许可发布他人私人信息

## 📞 **联系方式**

- **GitHub Issues**: 报告问题和建议
- **GitHub Discussions**: 社区交流
- **邮件**: support@gitsync-bridge.com
- **微信群**: 扫码加入开发者交流群

## 🎉 **感谢**

感谢每一位为GitSync-Bridge做出贡献的开发者！

[![Contributors](https://contrib.rocks/image?repo=your-username/GitSync-Bridge)](https://github.com/your-username/GitSync-Bridge/graphs/contributors)

---

**🌉 让我们一起为中国开发者搭建更好的代码桥梁！**