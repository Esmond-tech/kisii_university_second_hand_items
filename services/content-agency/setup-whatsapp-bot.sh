#!/bin/bash
# WhatsApp AI Agent Setup Script
# This sets up an automated WhatsApp responder for your business

echo "🤖 Kisii AI Services - WhatsApp Bot Setup"
echo "=========================================="
echo ""

# Configuration
BUSINESS_NAME="Kisii AI Services"
BUSINESS_PHONE="+254XXXXXXXXX"  # UPDATE THIS
OWNER_PHONE="+254XXXXXXXXX"     # UPDATE THIS

# Check if dependencies are installed
check_dependencies() {
    echo "📋 Checking dependencies..."
    
    # Check for Node.js
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js not found. Installing..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    # Check for PM2
    if ! command -v pm2 &> /dev/null; then
        echo "📦 Installing PM2..."
        sudo npm install -g pm2
    fi
    
    echo "✅ Dependencies ready!"
}

# Create WhatsApp bot script
create_bot_script() {
    echo "📝 Creating WhatsApp bot..."
    
    mkdir -p ~/whatsapp-bot
    cd ~/whatsapp-bot
    
    # Initialize npm project
    npm init -y
    
    # Install dependencies
    npm install whatsapp-web-dev qrcode-terminal axios
    
    # Create bot script
    cat > bot.js << 'EOF'
const { Client, LocalAuth } = require('whatsapp-web-dev');
const qrcode = require('qrcode-terminal');
const axios = require('axios');

const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: {
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    }
});

// Business configuration
const BUSINESS_NAME = "Kisii AI Services";
const PRICING = {
    starter: "KSh 6,500/month - 20 posts + 2 articles",
    business: "KSh 12,000/month - 50 posts + 5 articles + WhatsApp bot",
    enterprise: "KSh 25,000/month - Unlimited + custom solutions"
};

// Keywords and responses
const responses = {
    greeting: [`Hello! 👋 Welcome to ${BUSINESS_NAME}!`,
               "I'm your AI assistant. How can I help you today?",
               "We offer:\n📱 Social Media Management\n📝 Blog Writing\n🤖 WhatsApp Automation"],
    
    pricing: ["💰 Our pricing:",
              `\n🥉 Starter: ${PRICING.starter}`,
              `\n🥈 Business: ${PRICING.business}`,
              `\n🥇 Enterprise: ${PRICING.enterprise}`,
              "\nWhich plan interests you?"],
    
    contact: ["📞 You can reach us:",
              "WhatsApp: This number",
              "We'll get back to you within 24 hours!"],
    
    services: ["🎯 Our Services:",
               "\n📱 Social Media Management (50+ posts/month)",
               "📝 SEO Blog Articles (10 articles/month)",
               "💬 WhatsApp Automation (24/7 AI chatbot)",
               "🎨 Custom Graphics & Design",
               "📊 Analytics & Reporting"],
    
    samples: ["📱 Sample social media post:",
              "\n🔥 Transform your business with AI-powered marketing!\n\n✅ 50+ posts per month\n✅ Engaging content that converts\n✅ Affordable pricing\n\n💬 DM us for a FREE consultation!\n\n#KisiiBusiness #AI #DigitalMarketing",
              "\nWould you like to see more samples?"]
};

// Message handler
client.on('message_create', async (msg) => {
    // Don't respond to own messages
    if (msg.fromMe) return;
    
    const text = msg.body.toLowerCase();
    let response = "";
    
    // Check for keywords
    if (text.includes('hi') || text.includes('hello') || text.includes('hey')) {
        response = responses.greeting.join('\n');
    } else if (text.includes('price') || text.includes('cost') || text.includes('how much')) {
        response = responses.pricing.join('\n');
    } else if (text.includes('service') || text.includes('what do you do')) {
        response = responses.services.join('\n');
    } else if (text.includes('sample') || text.includes('example')) {
        response = responses.samples.join('\n');
    } else if (text.includes('contact') || text.includes('call') || text.includes('phone')) {
        response = responses.contact.join('\n');
    } else if (text.includes('interested') || text.includes('sign up') || text.includes('start')) {
        response = "🎉 Great! To get started, I'll need:\n\n1. Your business name\n2. What service you need\n3. Your email\n\nOur team will contact you within 1 hour to set everything up!";
    } else {
        response = "I can help you with:\n\n💰 Pricing info\n📱 Our services\n📄 Sample content\n💬 Getting started\n\nWhat would you like to know?";
    }
    
    // Send response with typing delay
    await new Promise(resolve => setTimeout(resolve, 1000));
    await msg.reply(response);
    
    // Log for analytics
    console.log(`[${new Date().toISOString()}] From: ${msg.from} | Message: ${msg.body.substring(0, 50)}...`);
});

client.on('qr', (qr) => {
    qrcode.generate(qr, { small: true });
    console.log('📱 Scan the QR code above with your WhatsApp!');
});

client.on('ready', () => {
    console.log('✅ WhatsApp Bot is ready!');
    console.log('🤖 Listening for messages...');
});

client.initialize();
EOF

    echo "✅ Bot script created!"
}

# Create PM2 config
create_pm2_config() {
    echo "⚙️ Creating PM2 config..."
    
    cat > ~/whatsapp-bot/ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'kisii-whatsapp-bot',
    script: './bot.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production'
    },
    log_file: './logs/combined.log',
    out_file: './logs/out.log',
    error_file: './logs/error.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
  }]
};
EOF

    mkdir -p ~/whatsapp-bot/logs
    echo "✅ PM2 config created!"
}

# Create startup script
create_startup_script() {
    echo "🚀 Creating startup script..."
    
    cat > ~/whatsapp-bot/start.sh << 'EOF'
#!/bin/bash
echo "🤖 Starting Kisii AI Services WhatsApp Bot..."
cd ~/whatsapp-bot
pm2 start ecosystem.config.js
echo "✅ Bot started!"
echo "📊 View logs: pm2 logs kisii-whatsapp-bot"
echo "🛑 Stop: pm2 stop kisii-whatsapp-bot"
EOF

    cat > ~/whatsapp-bot/stop.sh << 'EOF'
#!/bin/bash
echo "🛑 Stopping WhatsApp Bot..."
pm2 stop kisii-whatsapp-bot
echo "✅ Bot stopped!"
EOF

    chmod +x ~/whatsapp-bot/start.sh ~/whatsapp-bot/stop.sh
    echo "✅ Startup scripts created!"
}

# Create monitoring dashboard
create_dashboard() {
    echo "📊 Creating monitoring dashboard..."
    
    cat > ~/whatsapp-bot/stats.js << 'EOF'
const fs = require('fs');
const readline = require('readline');

async function showStats() {
    console.log("\n📊 Kisii AI Services - WhatsApp Bot Stats");
    console.log("==========================================");
    
    // Count messages in log
    try {
        const logFile = './logs/combined.log';
        if (fs.existsSync(logFile)) {
            const fileStream = fs.createReadStream(logFile);
            const rl = readline.createInterface({
                input: fileStream,
                crlfDelay: Infinity
            });
            
            let messageCount = 0;
            for await (const line of rl) {
                if (line.includes('From:')) messageCount++;
            }
            
            console.log(`💬 Total messages handled: ${messageCount}`);
            console.log(`⏰ Last updated: ${new Date().toLocaleString()}`);
        } else {
            console.log("📝 No messages yet. Bot is ready!");
        }
    } catch (err) {
        console.log("⚠️ Could not read stats:", err.message);
    }
}

showStats();
EOF

    echo "✅ Dashboard created!"
}

# Main installation
main() {
    echo "🎯 Starting setup..."
    check_dependencies
    create_bot_script
    create_pm2_config
    create_startup_script
    create_dashboard
    
    echo ""
    echo "✅ Setup Complete!"
    echo "=================="
    echo ""
    echo "🚀 To start your WhatsApp bot:"
    echo "   cd ~/whatsapp-bot"
    echo "   ./start.sh"
    echo ""
    echo "📱 First run: Scan QR code with your WhatsApp"
    echo "📊 View stats: node stats.js"
    echo "🛑 Stop bot: ./stop.sh"
    echo ""
    echo "💰 Business Setup Required:"
    echo "   1. Update BUSINESS_PHONE in bot.js"
    echo "   2. Update OWNER_PHONE for notifications"
    echo "   3. Test the bot with a friend"
    echo ""
    echo "🎯 Next Steps:"
    echo "   • Share your WhatsApp number on social media"
    echo "   • Add 'Chat on WhatsApp' button to your landing page"
    echo "   • Set up auto-replies for common questions"
    echo ""
}

# Run main function
main
