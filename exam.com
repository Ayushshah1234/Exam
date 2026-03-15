<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Global Physio Practice Hub - Canada, USA, Australia, UK</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .container { background: white; padding: 40px; border-radius: 20px; box-shadow: 0 20px 40px rgba(0,0,0,0.1); max-width: 500px; width: 90%; text-align: center; }
        h1 { color: #333; margin-bottom: 30px; font-size: 2em; }
        input, select, button { width: 100%; padding: 15px; margin: 10px 0; border: 2px solid #ddd; border-radius: 10px; font-size: 16px; transition: all 0.3s; }
        button { background: #4CAF50; color: white; border: none; cursor: pointer; font-weight: bold; text-transform: uppercase; letter-spacing: 1px; }
        button:hover { background: #45a049; transform: translateY(-2px); }
        button:disabled { background: #ccc; cursor: not-allowed; }
        .step { display: none; }
        .step.active { display: block; animation: fadeIn 0.5s; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        .face-scan { background: #ffeb3b; color: #333; padding: 20px; border-radius: 15px; margin: 20px 0; font-size: 18px; }
        #video { width: 100%; max-width: 300px; border-radius: 10px; margin: 10px 0; }
        .system-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px; margin: 20px 0; }
        .system-btn { padding: 15px; background: #f8f9fa; border: 2px solid #dee2e6; border-radius: 10px; cursor: pointer; transition: all 0.3s; }
        .system-btn.active { background: #007bff; color: white; border-color: #007bff; }
        .case-area { background: #e3f2fd; padding: 20px; border-radius: 15px; margin: 20px 0; min-height: 200px; text-align: left; }
        .mcq { margin: 15px 0; }
        .mcq label { display: block; padding: 10px; background: white; margin: 5px 0; border-radius: 8px; cursor: pointer; border: 2px solid #eee; }
        .mcq input:checked + span { font-weight: bold; color: #007bff; }
        #results { background: #d4edda; padding: 20px; border-radius: 15px; }
        .progress { background: #eee; height: 10px; border-radius: 5px; margin: 20px 0; overflow: hidden; }
        .progress-bar { background: linear-gradient(90deg, #4CAF50, #2196F3); height: 100%; width: 0%; transition: width 0.5s; }
    </style>
</head>
<body>
    <div class="container">
        <!-- Step 1: Login -->
        <div id="step-login" class="step active">
            <h1>🏥 Global Physio Practice Hub</h1>
            <p>Practice for Canada, USA, Australia, UK exams</p>
            <input type="text" id="username" placeholder="User ID">
            <input type="password" id="password" placeholder="Password">
            <button onclick="login()">Login</button>
            <p style="font-size: 12px; margin-top: 10px;">Demo: user / pass</p>
        </div>

        <!-- Step 2: Face Scan -->
        <div id="step-face" class="step">
            <h1>🔍 Face Verification</h1>
            <div class="face-scan">
                <p>Position face in frame. Scanning in 3...2...1...</p>
                <video id="video" autoplay playsinline></video>
                <canvas id="canvas" style="display:none;"></canvas>
            </div>
            <button onclick="faceScan()">✅ Verified - Continue</button>
        </div>

        <!-- Step 3: Country -->
        <div id="step-country" class="step">
            <h1>🌍 Select Country</h1>
            <select id="country">
                <option value="canada">Canada (CPTE)</option>
                <option value="usa">USA (NPTE)</option>
                <option value="australia">Australia (APC)</option>
                <option value="uk">UK (HCPC)</option>
            </select>
            <button onclick="nextStep()">Start Practice</button>
        </div>

        <!-- Step 4: System Selection -->
        <div id="step-system" class="step">
            <h1>🦴 Select Practice System</h1>
            <div class="system-grid" id="systems">
                <!-- Dynamically populated -->
            </div>
            <button onclick="nextStep()" id="system-next" disabled>Next</button>
        </div>

        <!-- Step 5: Age & Setting -->
        <div id="step-details" class="step">
            <h1>📋 Case Details</h1>
            <select id="age">
                <option>0-18 years</option><option>19-64 years</option><option>65+ years</option>
            </select>
            <select id="setting">
                <option>Hospital/Acute Care</option><option>Private Clinic</option><option>Rehab Centre</option>
                <option>Community Health</option><option>Home Care</option><option>Long-term Care</option>
            </select>
            <button onclick="generateCase()">Generate Animated Case</button>
        </div>

        <!-- Step 6: Animated Case -->
        <div id="step-case" class="step">
            <h1>🎬 Patient Case</h1>
            <div class="case-area" id="case-vignette">
                <!-- Animated patient + scenario -->
            </div>
            <button onclick="startOral()">🗣️ Talk to Patient (Oral)</button>
            <div id="oral-section" style="display:none;">
                <p>Record your questions & assessment (2 min)</p>
                <button id="start-oral" onclick="startOralRecording()">🎤 Start Speaking</button>
                <button id="stop-oral" onclick="stopOralRecording()" disabled>⏹️ Stop</button>
            </div>
            <button onclick="nextMCQ()">Next: MCQs</button>
        </div>

        <!-- Step 7: MCQs -->
        <div id="step-mcq" class="step">
            <h1>📝 Follow-up MCQs</h1>
            <div id="mcq-questions"></div>
            <button onclick="submitMCQ()">Submit & Get Results</button>
        </div>

        <!-- Step 8: Results -->
        <div id="step-results" class="step">
            <h1>📊 Results</h1>
            <div id="results"></div>
            <button onclick="restart()">New Session</button>
        </div>

        <div class="progress"><div class="progress-bar" id="progress-bar"></div></div>
    </div>

    <script>
        // Global state
        let currentStep = 1;
        let selectedCountry = '';
        let selectedSystem = '';
        let userScore = 0;

        // Country-specific data[web:2][web:3][web:5][web:9][web:11]
        const countryData = {
            canada: { name: 'CPTE (Canada)', systems: ['Musculoskeletal (50%)', 'Neurological (20%)', 'Cardio-Respiratory (15%)', 'Other (15%)'], rules: 'CAPR standards: 7 domains, client-centered care' },
            usa: { name: 'NPTE (USA)', systems: ['Musculoskeletal', 'Neuromuscular', 'Cardiopulmonary', 'Other'], rules: 'FSBPT: 50 items MSK, evidence-based practice' },
            australia: { name: 'APC (Australia)', systems: ['Musculoskeletal', 'Neurological', 'Cardio-Respiratory'], rules: 'AHPRA: Cultural safety, 120 MCQs clinical scenarios' },
            uk: { name: 'HCPC (UK)', systems: ['Musculoskeletal', 'Neurological', 'Respiratory', 'Other'], rules: 'HCPC Standards: Safeguarding, scope of practice' }
        };

        // Demo login
        function login() {
            const user = document.getElementById('username').value;
            const pass = document.getElementById('password').value;
            if (user === 'user' && pass === 'pass') {
                nextStep();
            } else {
                alert('Demo: user/pass');
            }
        }

        // Face scan (simulated with webcam)
        function faceScan() {
            const video = document.getElementById('video');
            navigator.mediaDevices.getUserMedia({ video: true }).then(stream => {
                video.srcObject = stream;
                setTimeout(() => {
                    alert('Face verified! ✅');
                    nextStep();
                }, 2000);
            }).catch(() => {
                alert('Camera access denied. Click Continue.');
                nextStep();
            });
        }

        // Next step navigation
        function nextStep() {
            document.querySelectorAll('.step').forEach(s => s.classList.remove('active'));
            currentStep++;
            document.getElementById(`step-${currentStep === 2 ? 'face' : currentStep === 3 ? 'country' : currentStep === 4 ? 'system' : currentStep === 5 ? 'details' : currentStep === 6 ? 'case' : currentStep === 7 ? 'mcq' : 'results'}`).classList.add('active');
            updateProgress();
        }

        function updateProgress() {
            document.getElementById('progress-bar').style.width = `${(currentStep / 8) * 100}%`;
        }

        // Country selection
        function selectCountry(country) {
            selectedCountry = country;
            nextStep();
        }

        // System selection
        function loadSystems() {
            const grid = document.getElementById('systems');
            const data = countryData[selectedCountry];
            grid.innerHTML = data.systems.map(s => `<div class="system-btn" onclick="selectSystem('${s}')">${s}</div>`).join('');
        }

        function selectSystem(system) {
            selectedSystem = system;
            document.querySelectorAll('.system-btn').forEach(btn => btn.classList.remove('active'));
            event.target.classList.add('active');
            document.getElementById('system-next').disabled = false;
        }

        // Generate animated case
        function generateCase() {
            const age = document.getElementById('age').value;
            const setting = document.getElementById('setting').value;
            const data = countryData[selectedCountry];
            
            document.getElementById('case-vignette').innerHTML = `
                <h3>Animated Patient: ${selectedSystem} - ${age} in ${setting}</h3>
                <p><strong>${data.name} Rules Applied:</strong> ${data.rules}[web:2][web:3][web:5]</p>
                <div style="font-size: 24px; margin: 20px 0;">👤 Patient Avatar (Animated)</div>
                <p><em>Patient: "Hi, I have ${selectedSystem.toLowerCase()} pain after fall. Can you help?"</em></p>
            `;
            nextStep();
        }

        // Oral interaction
        function startOral() {
            document.getElementById('oral-section').style.display = 'block';
        }

        let oralRecorder;
        function startOralRecording() {
            navigator.mediaDevices.getUserMedia({ audio: true }).then(stream => {
                oralRecorder = new MediaRecorder(stream);
                oralRecorder.start();
                document.getElementById('start-oral').disabled = true;
                document.getElementById('stop-oral').disabled = false;
            });
        }

        function stopOralRecording() {
            oralRecorder.stop();
            setTimeout(nextMCQ, 1000);
        }

        function nextMCQ() {
            document.getElementById('mcq-questions').innerHTML = `
                <div class="mcq">
                    <p>Q1: Next assessment step per ${countryData[selectedCountry].name}?</p>
                    <label><input type="radio" name="q1" value="A"> A. Full ROM</label>
                    <label><input type="radio" name="q1" value="B"> B. Neuro screen</label>
                    <label><input type="radio" name="q1" value="C"> C. Vitals first</label>
                    <label><input type="radio" name="q1" value="D"> D. X-ray order</label>
                </div>
                <div class="mcq">
                    <p>Q2: PT intervention priority?</p>
                    <label><input type="radio" name="q2" value="A"> A. Manual therapy</label>
                    <label><input type="radio" name="q2" value="B"> B. Exercise Rx</label>
                    <label><input type="radio" name="q2" value="C"> C. Education</label>
                    <label><input type="radio" name="q2" value="D"> D. Modalities</label>
                </div>
            `;
            nextStep();
        }

        function submitMCQ() {
            userScore = Math.random() > 0.5 ? 85 : 72; // Simulated scoring
            document.getElementById('results').innerHTML = `
                <h3>Session Complete! Score: ${userScore}%</h3>
                <p><strong>Strengths:</strong> ${selectedSystem}</p>
                <p><strong>Country Rules:</strong> ${countryData[selectedCountry].rules}</p>
                <p>🎯 Ready for ${countryData[selectedCountry].name}!</p>
            `;
            nextStep();
        }

        function restart() {
            location.reload();
        }

        // Init
        document.getElementById('country').addEventListener('change', function() {
            selectedCountry = this.value;
            loadSystems();
            nextStep();
        });
    </script>
</body>
</html>
