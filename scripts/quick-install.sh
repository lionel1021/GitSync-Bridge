#!/bin/bash

# 🌉 GitSync-Bridge 一键安装脚本
# Bridge Your Code to the World - 让你的代码走向世界

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 图标定义
ROCKET="🚀"
BRIDGE="🌉"
CHECK="✅"
CROSS="❌"
WARN="⚠️"
INFO="ℹ️"
GEAR="⚙️"

# 打印带颜色的消息
print_message() {
    local color=$1
    local icon=$2
    local message=$3
    echo -e "${color}${icon} ${message}${NC}"
}

print_header() {
    echo ""
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    ${BRIDGE} GitSync-Bridge ${BRIDGE}                    ║${NC}"
    echo -e "${PURPLE}║              Bridge Your Code to the World               ║${NC}"
    echo -e "${PURPLE}║                让你的代码走向世界                          ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    local step=$1
    local total=$2
    local message=$3
    echo ""
    print_message $CYAN "$GEAR" "[$step/$total] $message"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 检查必要工具
check_requirements() {
    print_step 1 6 "检查系统环境"
    
    # 检查git
    if ! command -v git &> /dev/null; then
        print_message $RED "$CROSS" "Git未安装，请先安装Git"
        exit 1
    fi
    print_message $GREEN "$CHECK" "Git已安装: $(git --version)"
    
    # 检查curl
    if ! command -v curl &> /dev/null; then
        print_message $RED "$CROSS" "curl未安装，请先安装curl"
        exit 1
    fi
    print_message $GREEN "$CHECK" "curl已安装"
    
    # 检查操作系统
    OS=$(uname -s)
    print_message $GREEN "$CHECK" "操作系统: $OS"
    
    print_message $GREEN "$CHECK" "系统环境检查完成"
}

# 获取用户输入
get_user_input() {
    print_step 2 6 "收集配置信息"
    
    echo "请提供以下信息来配置GitSync-Bridge："
    echo ""
    
    # GitHub用户名
    read -p "$(echo -e ${BLUE}🔹 GitHub用户名: ${NC})" GITHUB_USERNAME
    if [[ -z "$GITHUB_USERNAME" ]]; then
        print_message $RED "$CROSS" "GitHub用户名不能为空"
        exit 1
    fi
    
    # GitHub仓库名
    read -p "$(echo -e ${BLUE}🔹 GitHub仓库名: ${NC})" GITHUB_REPO
    if [[ -z "$GITHUB_REPO" ]]; then
        print_message $RED "$CROSS" "GitHub仓库名不能为空"
        exit 1
    fi
    
    # Gitee用户名
    read -p "$(echo -e ${BLUE}🔹 Gitee用户名: ${NC})" GITEE_USERNAME
    if [[ -z "$GITEE_USERNAME" ]]; then
        print_message $RED "$CROSS" "Gitee用户名不能为空"
        exit 1
    fi
    
    # Gitee仓库名
    read -p "$(echo -e ${BLUE}🔹 Gitee仓库名 (默认与GitHub相同): ${NC})" GITEE_REPO
    if [[ -z "$GITEE_REPO" ]]; then
        GITEE_REPO=$GITHUB_REPO
    fi
    
    # 同步频率
    echo ""
    echo "选择Gitee→GitHub同步频率:"
    echo "1) 每5分钟 (推荐)"
    echo "2) 每15分钟" 
    echo "3) 每30分钟"
    echo "4) 每小时"
    read -p "$(echo -e ${BLUE}🔹 请选择 (1-4): ${NC})" SYNC_FREQ
    
    case $SYNC_FREQ in
        1) CRON_SCHEDULE="*/5 * * * *" ;;
        2) CRON_SCHEDULE="*/15 * * * *" ;;
        3) CRON_SCHEDULE="*/30 * * * *" ;;
        4) CRON_SCHEDULE="0 * * * *" ;;
        *) CRON_SCHEDULE="*/15 * * * *" ;;
    esac
    
    print_message $GREEN "$CHECK" "配置信息收集完成"
}

# 创建项目目录
create_project_structure() {
    print_step 3 6 "创建项目结构"
    
    PROJECT_DIR="gitee-github-sync-$GITHUB_REPO"
    
    if [[ -d "$PROJECT_DIR" ]]; then
        print_message $WARN "$WARN" "目录 $PROJECT_DIR 已存在"
        read -p "$(echo -e ${YELLOW}是否删除并重新创建? (y/N): ${NC})" RECREATE
        if [[ "$RECREATE" =~ ^[Yy]$ ]]; then
            rm -rf "$PROJECT_DIR"
            print_message $GREEN "$CHECK" "已删除旧目录"
        else
            print_message $RED "$CROSS" "安装终止"
            exit 1
        fi
    fi
    
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
    
    # 创建目录结构
    mkdir -p .github/workflows
    mkdir -p scripts
    mkdir -p docs
    mkdir -p examples
    
    print_message $GREEN "$CHECK" "项目结构创建完成: $PROJECT_DIR"
}

# 生成GitHub Actions配置
generate_workflows() {
    print_step 4 6 "生成GitHub Actions配置"
    
    # GitHub → Gitee 同步
    cat > .github/workflows/sync-to-gitee.yml << EOF
name: 🔄 Sync to Gitee

on:
  push:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    name: 🌉 GitSync-Bridge to Gitee
    steps:
    - name: 📥 Checkout
      uses: actions/checkout@v4
      with:
        fetch-depth: 0

    - name: 🔄 Mirror to Gitee
      uses: Yikun/hub-mirror-action@master
      with:
        src: github/$GITHUB_USERNAME/$GITHUB_REPO
        dst: gitee/$GITEE_USERNAME/$GITEE_REPO
        dst_key: \${{ secrets.GITEE_PRIVATE_KEY }}
        dst_token: \${{ secrets.GITEE_PASSWORD }}
        force_update: true
        debug: true

    - name: 🚀 Build Gitee Pages
      uses: yanglbme/gitee-pages-action@main
      with:
        gitee-username: $GITEE_USERNAME
        gitee-password: \${{ secrets.GITEE_PASSWORD }}
        gitee-repo: $GITEE_USERNAME/$GITEE_REPO
        branch: main
EOF

    # Gitee → GitHub 同步
    cat > .github/workflows/pull-from-gitee.yml << EOF
name: 🔽 Pull from Gitee

on:
  schedule:
    - cron: '$CRON_SCHEDULE'
  workflow_dispatch:

jobs:
  pull:
    runs-on: ubuntu-latest
    name: 🌉 GitSync-Bridge from Gitee
    steps:
    - name: 📥 Checkout GitHub repo
      uses: actions/checkout@v4
      with:
        token: \${{ secrets.GITHUB_TOKEN }}
        fetch-depth: 0
        
    - name: ⚙️ Setup Git Config
      run: |
        git config --global user.name "GitSync-Bridge[bot]"
        git config --global user.email "gitsync-bridge@noreply.github.com"
        
    - name: 🔗 Add Gitee remote and fetch
      env:
        GITEE_TOKEN: \${{ secrets.GITEE_PASSWORD }}
      run: |
        git remote add gitee https://$GITEE_USERNAME:\${GITEE_TOKEN}@gitee.com/$GITEE_USERNAME/$GITEE_REPO.git || true
        git fetch gitee main
        
    - name: 🔍 Check for differences
      id: check_diff
      run: |
        if git diff --quiet HEAD gitee/main; then
          echo "has_changes=false" >> \$GITHUB_OUTPUT
          echo "📄 没有发现新的更改"
        else
          echo "has_changes=true" >> \$GITHUB_OUTPUT
          echo "🔄 发现Gitee有新的更改，准备同步"
        fi
        
    - name: 🔄 Merge and push changes
      if: steps.check_diff.outputs.has_changes == 'true'
      run: |
        git merge gitee/main --no-edit -m "🌉 GitSync-Bridge: 自动同步来自Gitee的更改 (\$(date))"
        git push origin main
        echo "✅ 成功同步Gitee更改到GitHub"
        
    - name: 📊 Log sync status
      run: |
        echo "🌉 GitSync-Bridge 同步状态报告:"
        echo "=================================="
        echo "🕒 同步时间: \$(date)"
        echo "📦 GitHub仓库: $GITHUB_USERNAME/$GITHUB_REPO"
        echo "📦 Gitee仓库: $GITEE_USERNAME/$GITEE_REPO"
        echo "🔄 是否有更改: \${{ steps.check_diff.outputs.has_changes }}"
        echo "✅ 同步完成"
EOF

    # 手动同步
    cat > .github/workflows/manual-sync.yml << EOF
name: 🎯 Manual Sync

on:
  workflow_dispatch:
    inputs:
      direction:
        description: '同步方向'
        required: true
        default: 'both'
        type: choice
        options:
        - github-to-gitee
        - gitee-to-github
        - both

jobs:
  manual-sync:
    runs-on: ubuntu-latest
    name: 🌉 GitSync-Bridge Manual Sync
    steps:
    - name: 📥 Checkout
      uses: actions/checkout@v4
      with:
        fetch-depth: 0
        
    - name: 🔄 GitHub to Gitee
      if: \${{ github.event.inputs.direction == 'github-to-gitee' || github.event.inputs.direction == 'both' }}
      uses: Yikun/hub-mirror-action@master
      with:
        src: github/$GITHUB_USERNAME/$GITHUB_REPO
        dst: gitee/$GITEE_USERNAME/$GITEE_REPO
        dst_key: \${{ secrets.GITEE_PRIVATE_KEY }}
        dst_token: \${{ secrets.GITEE_PASSWORD }}
        force_update: true
        
    - name: 🔽 Gitee to GitHub
      if: \${{ github.event.inputs.direction == 'gitee-to-github' || github.event.inputs.direction == 'both' }}
      run: |
        git config --global user.name "GitSync-Bridge[bot]"
        git config --global user.email "gitsync-bridge@noreply.github.com"
        git remote add gitee https://$GITEE_USERNAME:\${{ secrets.GITEE_PASSWORD }}@gitee.com/$GITEE_USERNAME/$GITEE_REPO.git || true
        git fetch gitee main
        git merge gitee/main --no-edit || echo "No changes to merge"
        git push origin main
EOF

    print_message $GREEN "$CHECK" "GitHub Actions配置生成完成"
}

# 生成辅助脚本
generate_scripts() {
    print_step 5 6 "生成辅助脚本"
    
    # SSH密钥生成脚本
    cat > scripts/generate-ssh-key.sh << 'EOF'
#!/bin/bash

echo "🔑 生成GitSync-Bridge SSH密钥"
echo "================================"

# 生成SSH密钥
ssh-keygen -t ed25519 -C "gitsync-bridge@noreply.github.com" -f ~/.ssh/gitsync_bridge_ed25519 -N ""

echo ""
echo "✅ SSH密钥已生成"
echo ""
echo "📋 请复制以下公钥到Gitee SSH设置中:"
echo "https://gitee.com/profile/sshkeys"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat ~/.ssh/gitsync_bridge_ed25519.pub
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔒 请复制以下私钥到GitHub Secrets中 (名称: GITEE_PRIVATE_KEY):"
echo "https://github.com/$GITHUB_USERNAME/$GITHUB_REPO/settings/secrets/actions"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat ~/.ssh/gitsync_bridge_ed25519
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
EOF

    chmod +x scripts/generate-ssh-key.sh
    
    # 测试脚本
    cat > scripts/test-sync.sh << EOF
#!/bin/bash

echo "🧪 GitSync-Bridge 同步测试"
echo "=========================="

# 创建测试文件
echo "# GitSync-Bridge 测试 - \$(date)" > SYNC_TEST.md
git add SYNC_TEST.md
git commit -m "🧪 GitSync-Bridge 同步测试 - \$(date +%H:%M:%S)"

echo "✅ 测试提交已创建"
echo "🚀 推送到GitHub以触发同步..."

git push origin main

echo ""
echo "📊 请查看以下链接确认同步状态:"
echo "• GitHub Actions: https://github.com/$GITHUB_USERNAME/$GITHUB_REPO/actions"
echo "• Gitee仓库: https://gitee.com/$GITEE_USERNAME/$GITEE_REPO"
EOF

    chmod +x scripts/test-sync.sh
    
    print_message $GREEN "$CHECK" "辅助脚本生成完成"
}

# 生成说明文档
generate_documentation() {
    print_step 6 6 "生成配置文档"
    
    cat > README.md << EOF
# 🌉 GitSync-Bridge 项目配置

> **Bridge Your Code to the World** - 让你的代码走向世界

## 📋 配置信息

- **GitHub仓库**: [\`$GITHUB_USERNAME/$GITHUB_REPO\`](https://github.com/$GITHUB_USERNAME/$GITHUB_REPO)
- **Gitee仓库**: [\`$GITEE_USERNAME/$GITEE_REPO\`](https://gitee.com/$GITEE_USERNAME/$GITEE_REPO)
- **同步频率**: $CRON_SCHEDULE

## 🚀 下一步操作

### 1. 推送到GitHub
\`\`\`bash
git init
git add .
git commit -m "🌉 初始化GitSync-Bridge配置"
git branch -M main
git remote add origin https://github.com/$GITHUB_USERNAME/$GITHUB_REPO.git
git push -u origin main
\`\`\`

### 2. 配置SSH密钥
\`\`\`bash
./scripts/generate-ssh-key.sh
\`\`\`

### 3. 配置GitHub Secrets
在GitHub仓库设置中添加以下Secrets:
- \`GITEE_PRIVATE_KEY\`: SSH私钥
- \`GITEE_PASSWORD\`: Gitee密码或访问令牌

### 4. 测试同步
\`\`\`bash
./scripts/test-sync.sh
\`\`\`

## 📊 监控链接

- **GitHub Actions**: https://github.com/$GITHUB_USERNAME/$GITHUB_REPO/actions
- **Gitee仓库**: https://gitee.com/$GITEE_USERNAME/$GITEE_REPO

## 🔧 故障排除

如果遇到问题，请检查:
1. GitHub Secrets是否正确配置
2. Gitee SSH密钥是否正确添加
3. 两个仓库是否都存在且可访问

---

*由 GitSync-Bridge 自动生成*
EOF

    print_message $GREEN "$CHECK" "配置文档生成完成"
}

# 主函数
main() {
    print_header
    
    print_message $BLUE "$ROCKET" "开始安装GitSync-Bridge..."
    
    check_requirements
    get_user_input
    create_project_structure
    generate_workflows
    generate_scripts
    generate_documentation
    
    echo ""
    print_message $GREEN "$CHECK" "🎉 GitSync-Bridge 安装完成!"
    echo ""
    echo -e "${CYAN}📁 项目目录: ${YELLOW}$(pwd)${NC}"
    echo -e "${CYAN}📖 配置说明: ${YELLOW}$(pwd)/README.md${NC}"
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🌉 恭喜! 您的代码桥梁已搭建完成!${NC}"
    echo -e "${GREEN}   现在可以让您的代码轻松走向世界! 🌍${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# 执行主函数
main "$@"
EOF