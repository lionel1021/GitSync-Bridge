# 🔧 GitSync-Bridge 故障排除指南

> 解决同步过程中可能遇到的各种问题

## 🚨 **常见问题快速定位**

### 问题分类
- 🔐 [认证问题](#认证问题)
- 🌐 [网络问题](#网络问题) 
- ⚙️ [配置问题](#配置问题)
- 🔄 [同步问题](#同步问题)
- 📊 [性能问题](#性能问题)

---

## 🔐 **认证问题**

### ❌ **错误**: `Authentication failed`

#### 症状
```
remote: [session-xxxxx] xxx: Incorrect username or password
fatal: Authentication failed for 'https://gitee.com/xxx/xxx.git/'
```

#### 解决方案

**1. 检查GITEE_PASSWORD配置**
```bash
# 确认Gitee私人访问令牌配置
# GitHub Settings → Secrets → GITEE_PASSWORD

# 测试令牌有效性
curl -H "Authorization: token YOUR_TOKEN" https://gitee.com/api/v5/user
```

**2. 重新生成Gitee访问令牌**
1. 访问 https://gitee.com/personal_access_tokens
2. 点击"生成新令牌"
3. 选择权限: `projects`, `user_info`, `emails`
4. 复制新令牌到GitHub Secrets

**3. 检查用户名配置**
```yaml
# 确保workflow中的用户名正确
dst: gitee/正确的用户名/正确的仓库名
```

### ❌ **错误**: `Permission denied (publickey)`

#### 症状
```
git@gitee.com: Permission denied (publickey).
fatal: Could not read from remote repository.
```

#### 解决方案

**1. 检查SSH密钥配置**
```bash
# 测试SSH连接
ssh -T git@gitee.com

# 应该看到类似输出:
# Hi xxx! You've successfully authenticated...
```

**2. 重新生成SSH密钥**
```bash
# 生成新的SSH密钥
ssh-keygen -t ed25519 -C "gitsync-bridge@example.com" -f ~/.ssh/gitee_key

# 添加公钥到Gitee
cat ~/.ssh/gitee_key.pub  # 复制到Gitee SSH设置

# 添加私钥到GitHub Secrets
cat ~/.ssh/gitee_key      # 复制到GITEE_PRIVATE_KEY
```

---

## 🌐 **网络问题**

### ❌ **错误**: `Connection timeout`

#### 症状
```
fatal: unable to access 'https://gitee.com/': 
Failed to connect to gitee.com port 443: Connection timed out
```

#### 解决方案

**1. GitHub Actions网络问题**
```yaml
# 在workflow中增加重试机制
- name: 🔄 Sync with retry
  uses: nick-invision/retry@v2
  with:
    timeout_minutes: 10
    max_attempts: 3
    retry_on: error
    command: |
      # 你的同步命令
```

**2. 使用备选同步方法**
```yaml
# 切换到HTTPS认证方式
- name: 🔄 HTTPS Sync Fallback
  run: |
    git remote set-url origin https://${{ vars.GITEE_USERNAME }}:${{ secrets.GITEE_PASSWORD }}@gitee.com/${{ vars.GITEE_USERNAME }}/${{ vars.GITEE_REPO }}.git
    git push origin main --force
```

### ❌ **错误**: `DNS resolution failed`

#### 解决方案
```yaml
# 在workflow中添加DNS配置
- name: 🔧 Configure DNS
  run: |
    echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
    echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf
```

---

## ⚙️ **配置问题**

### ❌ **错误**: `Repository not found`

#### 症状
```
remote: Repository not found.
fatal: repository 'https://gitee.com/xxx/xxx.git/' not found
```

#### 解决方案

**1. 检查仓库名配置**
```yaml
# 确认Variables配置正确
GITEE_USERNAME: 你的Gitee用户名
GITEE_REPO: 你的Gitee仓库名
GITHUB_USERNAME: 你的GitHub用户名  
GITHUB_REPO: 你的GitHub仓库名
```

**2. 验证仓库存在**
```bash
# 检查Gitee仓库
curl -I https://gitee.com/你的用户名/你的仓库名

# 应该返回 200 OK 或 403 Forbidden (私有仓库)
```

**3. 创建缺失的仓库**
- 在Gitee创建同名仓库
- 确保仓库名与配置完全一致

### ❌ **错误**: `Workflow file is invalid`

#### 症状
GitHub Actions页面显示workflow语法错误

#### 解决方案

**1. 检查YAML语法**
```bash
# 使用在线YAML验证器
# https://yaml-online-parser.appspot.com/

# 或使用yamllint
pip install yamllint
yamllint .github/workflows/*.yml
```

**2. 常见语法错误**
```yaml
# ❌ 错误: 缩进不一致
jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout  # 缩进错误
    uses: actions/checkout@v4

# ✅ 正确: 统一缩进
jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v4
```

---

## 🔄 **同步问题**

### ❌ **错误**: `Merge conflict`

#### 症状
```
Auto-merging file.txt
CONFLICT (content): Merge conflict in file.txt
Automatic merge failed
```

#### 解决方案

**1. 自动冲突解决**
```yaml
- name: 🔄 Merge with conflict resolution
  run: |
    git fetch gitee main
    
    # 尝试自动合并
    if ! git merge gitee/main --no-edit; then
      echo "🔧 检测到冲突，使用策略解决"
      
      # 策略1: 使用我们的版本 (GitHub优先)
      git checkout --ours .
      git add .
      git commit -m "🔧 解决冲突: 使用GitHub版本"
      
      # 策略2: 使用他们的版本 (Gitee优先)  
      # git checkout --theirs .
      # git add .
      # git commit -m "🔧 解决冲突: 使用Gitee版本"
    fi
```

**2. 通知机制**
```yaml
- name: 📧 Notify conflict
  if: failure()
  run: |
    # 创建Issue通知冲突
    gh issue create \
      --title "🔥 同步冲突需要手动处理" \
      --body "检测到合并冲突，请手动解决后重新同步"
```

### ❌ **错误**: `No changes to sync`

#### 症状
同步显示成功但没有实际同步内容

#### 解决方案

**1. 强制同步检查**
```yaml
- name: 🔍 Force sync check
  run: |
    # 获取最新提交hash
    LOCAL_HASH=$(git rev-parse HEAD)
    REMOTE_HASH=$(git ls-remote gitee main | cut -f1)
    
    echo "Local: $LOCAL_HASH"
    echo "Remote: $REMOTE_HASH"
    
    if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
      echo "🔄 发现差异，强制同步"
      git push gitee main --force
    fi
```

---

## 📊 **性能问题**

### ❌ **问题**: 同步速度慢

#### 优化方案

**1. 使用浅克隆**
```yaml
- name: 📥 Checkout (shallow)
  uses: actions/checkout@v4
  with:
    fetch-depth: 1  # 只获取最新提交
```

**2. 压缩传输**
```yaml
- name: 🗜️ Configure git compression
  run: |
    git config --global core.compression 9
    git config --global core.preloadindex true
```

**3. 并行处理**
```yaml
jobs:
  sync-to-gitee:
    runs-on: ubuntu-latest
    # 并行运行
  
  pull-from-gitee:
    runs-on: ubuntu-latest
    # 并行运行
```

### ❌ **问题**: 大文件同步失败

#### 解决方案

**1. 启用Git LFS**
```yaml
- name: 📦 Setup Git LFS
  run: |
    git lfs install
    git lfs track "*.zip" "*.tar.gz" "*.pdf"
    git add .gitattributes
```

**2. 分批同步**
```bash
# 排除大文件目录
rsync -av --exclude='*.iso' --exclude='dist/' src/ dst/
```

---

## 🔧 **调试工具**

### 启用详细日志
```yaml
- name: 🐛 Debug sync
  env:
    ACTIONS_RUNNER_DEBUG: true
    ACTIONS_STEP_DEBUG: true
  run: |
    # 你的同步命令
```

### 测试脚本
```bash
#!/bin/bash
# debug-sync.sh

echo "🔍 GitSync-Bridge 调试信息"
echo "========================="

# 检查环境变量
echo "📋 环境变量:"
echo "GITHUB_REPOSITORY: $GITHUB_REPOSITORY"
echo "GITEE_USERNAME: $GITEE_USERNAME" 
echo "GITEE_REPO: $GITEE_REPO"

# 检查网络连接
echo "🌐 网络连接测试:"
ping -c 3 gitee.com
ping -c 3 github.com

# 检查Git配置
echo "⚙️ Git配置:"
git config --list | grep -E "(user|remote)"

# 检查仓库状态
echo "📊 仓库状态:"
git status --porcelain
git log --oneline -5
```

---

## 📞 **获取帮助**

如果以上解决方案都不能解决你的问题，可以：

1. **查看GitHub Actions日志**
   - 详细的错误信息和堆栈跟踪
   
2. **创建Issue报告**
   - 包含错误信息、配置信息、重现步骤
   
3. **加入讨论区**
   - GitHub Discussions: https://github.com/your-username/GitSync-Bridge/discussions
   
4. **联系维护者**
   - 邮件: support@gitsync-bridge.com
   - 微信群: [扫码加入]

---

## 📚 **相关文档**

- [快速开始指南](quick-start.md)
- [高级配置](advanced-config.md) 
- [API参考](api-reference.md)
- [使用案例](../examples/)

---

**💡 提示**: 大多数问题都是由于认证配置不正确导致的，请首先检查Secrets和SSH配置！