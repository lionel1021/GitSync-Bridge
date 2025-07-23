# 🚀 GitSync-Bridge 快速开始指南

> **Bridge Your Code to the World** - 5分钟搭建你的代码桥梁

## 🎯 **准备工作**

在开始之前，请确保你已经：

- [ ] 拥有GitHub和Gitee账户
- [ ] 在两个平台创建了对应的仓库
- [ ] 本地安装了Git客户端

## ⚡ **方式一：一键自动安装 (推荐)**

### 1. 运行安装脚本
```bash
curl -fsSL https://raw.githubusercontent.com/your-username/GitSync-Bridge/main/scripts/quick-install.sh | bash
```

### 2. 按照提示输入配置信息
- GitHub用户名和仓库名
- Gitee用户名和仓库名  
- 同步频率选择

### 3. 推送到GitHub
```bash
cd gitee-github-sync-你的仓库名
git init
git add .
git commit -m "🌉 初始化GitSync-Bridge配置"
git branch -M main
git remote add origin https://github.com/你的用户名/你的仓库名.git
git push -u origin main
```

### 4. 配置认证信息
```bash
# 生成SSH密钥
./scripts/generate-ssh-key.sh

# 按照提示将公钥添加到Gitee，私钥添加到GitHub Secrets
```

## 🛠️ **方式二：手动配置**

### 1. 克隆模板项目
```bash
git clone https://github.com/your-username/GitSync-Bridge.git
cd GitSync-Bridge
```

### 2. 复制workflow文件到你的项目
```bash
# 复制到你的项目目录
cp -r .github/workflows /path/to/your/project/
cp -r scripts /path/to/your/project/
```

### 3. 修改配置文件
编辑 `.github/workflows/sync-to-gitee.yml` 和 `.github/workflows/pull-from-gitee.yml`，替换以下变量：

- `${{ vars.GITHUB_USERNAME }}` → 你的GitHub用户名
- `${{ vars.GITEE_USERNAME }}` → 你的Gitee用户名  
- `${{ vars.GITHUB_REPO }}` → 你的GitHub仓库名
- `${{ vars.GITEE_REPO }}` → 你的Gitee仓库名

### 4. 配置GitHub Repository Variables
在GitHub仓库设置中添加以下Variables：
- `GITHUB_USERNAME`: 你的GitHub用户名
- `GITHUB_REPO`: 你的GitHub仓库名
- `GITEE_USERNAME`: 你的Gitee用户名
- `GITEE_REPO`: 你的Gitee仓库名

## 🔐 **配置认证信息**

### GitHub Secrets配置
在 `https://github.com/你的用户名/你的仓库名/settings/secrets/actions` 添加：

#### 必需的Secrets
- **`GITEE_PASSWORD`**: Gitee密码或私人访问令牌
  ```
  获取方法: 
  1. Gitee → 设置 → 私人令牌 → 生成新令牌
  2. 选择权限: projects, user_info, emails
  3. 复制生成的令牌
  ```

#### 可选的Secrets (推荐，更安全)
- **`GITEE_PRIVATE_KEY`**: SSH私钥
  ```bash
  # 生成SSH密钥
  ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/gitee_key
  
  # 将公钥添加到Gitee
  cat ~/.ssh/gitee_key.pub  # 复制到Gitee SSH设置
  
  # 将私钥添加到GitHub Secrets
  cat ~/.ssh/gitee_key      # 复制到GITEE_PRIVATE_KEY
  ```

### Gitee SSH设置
1. 访问 https://gitee.com/profile/sshkeys
2. 点击"添加公钥"
3. 粘贴你的公钥内容
4. 设置标题为 "GitSync-Bridge"

## 🧪 **测试同步功能**

### 1. 测试GitHub → Gitee同步
```bash
# 在你的项目目录下
echo "# GitSync-Bridge 测试 - $(date)" > SYNC_TEST.md
git add SYNC_TEST.md
git commit -m "🧪 测试GitHub到Gitee同步"
git push origin main

# 几分钟后检查Gitee仓库是否有这个文件
```

### 2. 测试Gitee → GitHub同步
1. 直接在Gitee网页界面创建或编辑一个文件
2. 等待15分钟 (或手动触发Actions)
3. 检查GitHub仓库是否同步了更改

### 3. 手动触发同步
访问 `https://github.com/你的用户名/你的仓库名/actions`，选择对应的workflow，点击"Run workflow"

## 📊 **监控同步状态**

### GitHub Actions监控
- **同步状态**: https://github.com/你的用户名/你的仓库名/actions
- **健康检查**: 每6小时自动运行
- **失败通知**: 自动创建Issue提醒

### 实时状态徽章
在你的README中添加状态徽章：

```markdown
![GitHub to Gitee](https://github.com/你的用户名/你的仓库名/workflows/🔄%20Sync%20to%20Gitee/badge.svg)
![Gitee to GitHub](https://github.com/你的用户名/你的仓库名/workflows/🔽%20Pull%20from%20Gitee/badge.svg)
```

## 🔧 **常见问题排查**

### 同步失败
1. **检查Secrets配置**
   ```bash
   # 确认Secrets是否正确配置
   # GITEE_PASSWORD 或 GITEE_PRIVATE_KEY
   ```

2. **检查仓库权限**
   - GitHub仓库是否允许Actions
   - Gitee仓库是否可访问
   - SSH密钥是否正确添加

3. **查看详细日志**
   - GitHub Actions页面查看运行日志
   - 检查具体的错误信息

### 同步延迟
- GitHub → Gitee: 实时同步，通常1-3分钟
- Gitee → GitHub: 定时同步，最多15分钟

### 冲突处理
如果两边同时有更改：
1. 系统会尝试自动合并
2. 如果有冲突，会创建Issue通知
3. 需要手动解决冲突后重新同步

## 🎨 **高级配置**

### 自定义同步频率
编辑 `.github/workflows/pull-from-gitee.yml`：
```yaml
schedule:
  - cron: '*/5 * * * *'   # 每5分钟
  - cron: '*/30 * * * *'  # 每30分钟
  - cron: '0 * * * *'     # 每小时
```

### 排除特定文件
在workflow中添加：
```yaml
- name: 🔄 Sync with exclusions
  run: |
    # 排除特定文件或目录
    rsync -av --exclude='*.log' --exclude='node_modules/' src/ dst/
```

### 多分支同步
修改workflow的触发条件：
```yaml
on:
  push:
    branches: [ main, develop, release/* ]
```

## 🎉 **完成！**

现在你的代码仓库已经实现了GitHub和Gitee的双向自动同步！

### 🔗 **有用链接**
- [进阶配置指南](advanced-config.md)
- [故障排除手册](troubleshooting.md)
- [API参考文档](api-reference.md)
- [使用案例分享](../examples/)

---

**🌉 恭喜！你的代码桥梁已经搭建完成，现在可以让代码轻松走向世界！**