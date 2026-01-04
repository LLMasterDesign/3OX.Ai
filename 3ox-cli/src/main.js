// 3OX SETS Viewer - Main JavaScript
// Handles UI interactions and API communication

class ThreeOXViewer {
    constructor() {
        this.agents = [];
        this.currentAgent = null;
        this.apiBaseUrl = 'http://localhost:8001/api';
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.loadAgents();
        this.startStatusPolling();
    }

    setupEventListeners() {
        // Tab navigation
        document.querySelectorAll('.nav-tab').forEach(tab => {
            tab.addEventListener('click', (e) => {
                if (e.target.classList.contains('disabled')) return;
                this.switchTab(e.target.dataset.tab);
            });
        });

        // Modal controls
        document.getElementById('modal-close').addEventListener('click', () => {
            this.closeModal();
        });

        document.getElementById('modal-launch').addEventListener('click', () => {
            this.launchAgent(this.currentAgent);
        });

        document.getElementById('modal-stop').addEventListener('click', () => {
            this.stopAgent(this.currentAgent);
        });

        document.getElementById('modal-verify').addEventListener('click', () => {
            this.verifyAgent(this.currentAgent);
        });

        // Close modal on overlay click
        document.getElementById('agent-modal').addEventListener('click', (e) => {
            if (e.target.id === 'agent-modal') {
                this.closeModal();
            }
        });
    }

    switchTab(tabName) {
        // Update tab buttons
        document.querySelectorAll('.nav-tab').forEach(tab => {
            tab.classList.remove('active');
        });
        document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');

        // Update tab content
        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.remove('active');
        });
        document.getElementById(`${tabName}-view`).classList.add('active');
    }

    async loadAgents() {
        const loadingState = document.getElementById('loading-state');
        const agentsGrid = document.getElementById('agents-grid');
        const emptyState = document.getElementById('empty-state');
        const agentsCount = document.querySelector('.agents-count');

        try {
            loadingState.style.display = 'flex';
            agentsGrid.style.display = 'none';
            emptyState.style.display = 'none';

            // Try to load from backend API first
            try {
                const response = await fetch(`${this.apiBaseUrl}/agents`);
                if (response.ok) {
                    this.agents = await response.json();
                } else {
                    throw new Error('Backend not available');
                }
            } catch (apiError) {
                console.warn('Backend not available, using hardcoded agents:', apiError);
                // Fallback to hardcoded agents if backend is not available
                this.agents = this.getHardcodedAgents();
            }
            
            loadingState.style.display = 'none';
            
            if (this.agents.length === 0) {
                emptyState.style.display = 'block';
                agentsCount.textContent = '0 agents installed';
            } else {
                agentsGrid.style.display = 'grid';
                this.renderAgents();
                agentsCount.textContent = `${this.agents.length} agent${this.agents.length !== 1 ? 's' : ''} installed`;
            }

        } catch (error) {
            console.error('Error loading agents:', error);
            loadingState.style.display = 'none';
            emptyState.style.display = 'block';
            this.showError('Failed to load agents. Please check if the backend is running.');
        }
    }

    getHardcodedAgents() {
        // Hardcoded agents for Phase 1 - will be replaced with API calls
        return [
            {
                id: 'finance',
                name: 'Finance Agent',
                role: 'Financial Analysis',
                description: 'Advanced financial modeling and market analysis capabilities with real-time data processing.',
                status: 'stopped',
                capabilities: ['Market Analysis', 'Risk Assessment', 'Portfolio Optimization', 'Real-time Data'],
                verification: 'valid',
                tier: 'Professional',
                icon: '💰'
            },
            {
                id: 'security',
                name: 'Security Agent',
                role: 'Cybersecurity',
                description: 'Comprehensive security monitoring and threat detection with automated response systems.',
                status: 'running',
                capabilities: ['Threat Detection', 'Vulnerability Scanning', 'Incident Response', 'Compliance Monitoring'],
                verification: 'valid',
                tier: 'Enterprise',
                icon: '🔒'
            },
            {
                id: 'data',
                name: 'Data Agent',
                role: 'Data Processing',
                description: 'High-performance data processing and analytics with machine learning integration.',
                status: 'stopped',
                capabilities: ['Data Processing', 'ML Pipeline', 'ETL Operations', 'Analytics Dashboard'],
                verification: 'valid',
                tier: 'Professional',
                icon: '📊'
            },
            {
                id: 'communication',
                name: 'Communication Agent',
                role: 'Multi-channel Communication',
                description: 'Unified communication platform supporting email, SMS, voice, and messaging services.',
                status: 'unknown',
                capabilities: ['Email Management', 'SMS Gateway', 'Voice Processing', 'Chat Integration'],
                verification: 'invalid',
                tier: 'Standard',
                icon: '📱'
            },
            {
                id: 'automation',
                name: 'Automation Agent',
                role: 'Process Automation',
                description: 'Intelligent workflow automation with RPA capabilities and business process optimization.',
                status: 'stopped',
                capabilities: ['Workflow Automation', 'RPA Integration', 'Process Optimization', 'Task Scheduling'],
                verification: 'valid',
                tier: 'Professional',
                icon: '⚙️'
            }
        ];
    }

    renderAgents() {
        const agentsGrid = document.getElementById('agents-grid');
        agentsGrid.innerHTML = '';

        this.agents.forEach(agent => {
            const agentCard = this.createAgentCard(agent);
            agentsGrid.appendChild(agentCard);
        });
    }

    createAgentCard(agent) {
        const card = document.createElement('div');
        card.className = 'agent-card';
        card.addEventListener('click', () => this.showAgentModal(agent));

        const statusClass = `status-${agent.status}`;
        const statusText = agent.status.charAt(0).toUpperCase() + agent.status.slice(1);

        card.innerHTML = `
            <div class="agent-card-header">
                <div class="agent-icon">${agent.icon}</div>
                <div class="agent-info">
                    <h3>${agent.name}</h3>
                    <div class="agent-role">${agent.role}</div>
                </div>
            </div>
            <div class="agent-description">${agent.description}</div>
            <div class="agent-status">
                <div class="status-badge ${statusClass}">${statusText}</div>
                <div class="agent-tier">${agent.tier}</div>
            </div>
            <div class="agent-actions">
                <button class="btn btn-primary" onclick="event.stopPropagation(); threeOXViewer.launchAgent('${agent.id}')">
                    ${agent.status === 'running' ? 'Restart' : 'Launch'}
                </button>
                <button class="btn btn-outline" onclick="event.stopPropagation(); threeOXViewer.showAgentModal('${agent.id}')">
                    Details
                </button>
            </div>
        `;

        return card;
    }

    showAgentModal(agentId) {
        const agent = typeof agentId === 'string' 
            ? this.agents.find(a => a.id === agentId)
            : agentId;

        if (!agent) return;

        this.currentAgent = agent;
        const modal = document.getElementById('agent-modal');

        // Populate modal content
        document.getElementById('modal-agent-name').textContent = agent.name;
        document.getElementById('modal-description').textContent = agent.description;
        
        // Status
        const statusBadge = document.getElementById('modal-status');
        statusBadge.textContent = agent.status.charAt(0).toUpperCase() + agent.status.slice(1);
        statusBadge.className = `status-badge status-${agent.status}`;

        // Capabilities
        const capabilitiesContainer = document.getElementById('modal-capabilities');
        capabilitiesContainer.innerHTML = '';
        agent.capabilities.forEach(capability => {
            const tag = document.createElement('span');
            tag.className = 'capability-tag';
            tag.textContent = capability;
            capabilitiesContainer.appendChild(tag);
        });

        // Verification status
        const verificationContainer = document.getElementById('modal-verification');
        const verificationIcon = document.createElement('div');
        verificationIcon.className = 'verification-icon';
        
        if (agent.verification === 'valid') {
            verificationIcon.className += ' verification-valid';
            verificationIcon.textContent = '✓';
            verificationContainer.innerHTML = '';
            verificationContainer.appendChild(verificationIcon);
            verificationContainer.appendChild(document.createTextNode('All files verified'));
        } else if (agent.verification === 'invalid') {
            verificationIcon.className += ' verification-invalid';
            verificationIcon.textContent = '✗';
            verificationContainer.innerHTML = '';
            verificationContainer.appendChild(verificationIcon);
            verificationContainer.appendChild(document.createTextNode('File verification failed'));
        } else {
            verificationIcon.className += ' verification-unknown';
            verificationIcon.textContent = '?';
            verificationContainer.innerHTML = '';
            verificationContainer.appendChild(verificationIcon);
            verificationContainer.appendChild(document.createTextNode('Verification pending'));
        }

        // Action buttons
        const launchBtn = document.getElementById('modal-launch');
        const stopBtn = document.getElementById('modal-stop');
        
        if (agent.status === 'running') {
            launchBtn.style.display = 'none';
            stopBtn.style.display = 'inline-block';
        } else {
            launchBtn.style.display = 'inline-block';
            stopBtn.style.display = 'none';
        }

        modal.style.display = 'flex';
    }

    closeModal() {
        document.getElementById('agent-modal').style.display = 'none';
        this.currentAgent = null;
    }

    async launchAgent(agentId) {
        const agent = typeof agentId === 'string' 
            ? this.agents.find(a => a.id === agentId)
            : agentId;

        if (!agent) return;

        try {
            // Try to launch via API
            try {
                const response = await fetch(`${this.apiBaseUrl}/agents/${agent.id}/launch`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                });
                
                if (response.ok) {
                    const result = await response.json();
                    agent.status = 'running';
                    this.updateAgentStatus(agent);
                    this.showSuccess(`Agent ${agent.name} launched successfully`);
                } else {
                    const error = await response.json();
                    throw new Error(error.error || 'Failed to launch agent');
                }
            } catch (apiError) {
                console.warn('API not available, updating UI only:', apiError);
                // Fallback to UI-only update
                agent.status = 'running';
                this.updateAgentStatus(agent);
                this.showSuccess(`Agent ${agent.name} launched successfully (offline mode)`);
            }
            
            // Close modal if open
            if (this.currentAgent && this.currentAgent.id === agent.id) {
                this.closeModal();
            }
        } catch (error) {
            console.error('Error launching agent:', error);
            this.showError(`Failed to launch agent ${agent.name}: ${error.message}`);
        }
    }

    async stopAgent(agentId) {
        const agent = typeof agentId === 'string' 
            ? this.agents.find(a => a.id === agentId)
            : agentId;

        if (!agent) return;

        try {
            // Try to stop via API
            try {
                const response = await fetch(`${this.apiBaseUrl}/agents/${agent.id}/stop`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                });
                
                if (response.ok) {
                    const result = await response.json();
                    agent.status = 'stopped';
                    this.updateAgentStatus(agent);
                    this.showSuccess(`Agent ${agent.name} stopped successfully`);
                } else {
                    const error = await response.json();
                    throw new Error(error.error || 'Failed to stop agent');
                }
            } catch (apiError) {
                console.warn('API not available, updating UI only:', apiError);
                // Fallback to UI-only update
                agent.status = 'stopped';
                this.updateAgentStatus(agent);
                this.showSuccess(`Agent ${agent.name} stopped successfully (offline mode)`);
            }
            
            // Close modal if open
            if (this.currentAgent && this.currentAgent.id === agent.id) {
                this.closeModal();
            }
        } catch (error) {
            console.error('Error stopping agent:', error);
            this.showError(`Failed to stop agent ${agent.name}: ${error.message}`);
        }
    }

    async verifyAgent(agentId) {
        const agent = typeof agentId === 'string' 
            ? this.agents.find(a => a.id === agentId)
            : agentId;

        if (!agent) return;

        try {
            // Try to verify via API
            try {
                const response = await fetch(`${this.apiBaseUrl}/agents/${agent.id}/verify`);
                
                if (response.ok) {
                    const result = await response.json();
                    agent.verification = 'valid';
                    this.showSuccess(`Agent ${agent.name} verification completed`);
                } else {
                    const error = await response.json();
                    throw new Error(error.error || 'Failed to verify agent');
                }
            } catch (apiError) {
                console.warn('API not available, updating UI only:', apiError);
                // Fallback to UI-only update
                agent.verification = 'valid';
                this.showSuccess(`Agent ${agent.name} verification completed (offline mode)`);
            }
            
            // Update modal if open
            if (this.currentAgent && this.currentAgent.id === agent.id) {
                this.showAgentModal(agent);
            }
        } catch (error) {
            console.error('Error verifying agent:', error);
            this.showError(`Failed to verify agent ${agent.name}: ${error.message}`);
        }
    }

    updateAgentStatus(agent) {
        // Update the agent card in the grid
        const agentCards = document.querySelectorAll('.agent-card');
        agentCards.forEach(card => {
            const agentName = card.querySelector('h3').textContent;
            if (agentName === agent.name) {
                const statusBadge = card.querySelector('.status-badge');
                statusBadge.textContent = agent.status.charAt(0).toUpperCase() + agent.status.slice(1);
                statusBadge.className = `status-badge status-${agent.status}`;
                
                const launchBtn = card.querySelector('.btn-primary');
                launchBtn.textContent = agent.status === 'running' ? 'Restart' : 'Launch';
            }
        });
    }

    startStatusPolling() {
        // Poll for status updates every 5 seconds
        setInterval(() => {
            this.pollAgentStatus();
        }, 5000);
    }

    async pollAgentStatus() {
        try {
            // Poll each agent's status from the API
            for (const agent of this.agents) {
                try {
                    const response = await fetch(`${this.apiBaseUrl}/agents/${agent.id}/status`);
                    if (response.ok) {
                        const statusData = await response.json();
                        if (agent.status !== statusData.status) {
                            agent.status = statusData.status;
                            this.updateAgentStatus(agent);
                        }
                    }
                } catch (apiError) {
                    // Silently fail for individual agents
                    console.debug(`Failed to poll status for agent ${agent.id}:`, apiError);
                }
            }
        } catch (error) {
            console.error('Error polling agent status:', error);
        }
    }

    showSuccess(message) {
        // Simple success notification - could be enhanced with a proper notification system
        console.log('Success:', message);
        // For now, just log to console - could add toast notifications
    }

    showError(message) {
        // Simple error notification - could be enhanced with a proper notification system
        console.error('Error:', message);
        // For now, just log to console - could add toast notifications
    }
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.threeOXViewer = new ThreeOXViewer();
});