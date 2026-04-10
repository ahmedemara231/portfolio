'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "42aec476ff0a9d115dda57efe3b9cae8",
"skills-lock.json": "a075152e2b6f4863644e618505396c3c",
".vercel/project.json": "9f24db2306615d9e23d2404ba84eec5e",
".vercel/README.txt": "2b13c79d37d6ed82a3255b83b6815034",
"version.json": "191595f72c94967ff44fc676a3aedb8c",
"index.html": "1cec82240de70cbd49a99108b6409225",
"/": "1cec82240de70cbd49a99108b6409225",
"vercel.json": "6411d2fbb5f0e00aaff0ca0ded84e0b6",
".firebase/hosting.bg.cache": "215b3386c8b6eb991093a70710baf969",
"main.dart.js": "a68a07e5da42b7d2379519930caf3ff7",
".agents/skills/developing-genkit-go/references/providers.md": "94becc597b1f53fded34d38e61679a6c",
".agents/skills/developing-genkit-go/references/flows-and-http.md": "b7dede1526f535cf99fb638b17c820e8",
".agents/skills/developing-genkit-go/references/getting-started.md": "1333864b7cbce4ab8696d44860ac52da",
".agents/skills/developing-genkit-go/references/generation.md": "4b7fc8e220157abbe5912faa021d3860",
".agents/skills/developing-genkit-go/references/prompts.md": "65e26a3d263a3e7a12d45b0a4680ff81",
".agents/skills/developing-genkit-go/references/tools.md": "aac61ff499acfd348f693240ce641231",
".agents/skills/developing-genkit-go/SKILL.md": "81e9c40e9c15dfd4cdbc873663ecd782",
".agents/skills/firebase-auth-basics/references/client_sdk_web.md": "f31721854ba740d8ce04d550e1af8b4f",
".agents/skills/firebase-auth-basics/references/security_rules.md": "825de231c117fdc362581e8738283310",
".agents/skills/firebase-auth-basics/SKILL.md": "cc98edf7a721e34e37ea73d5f58ac391",
".agents/skills/developing-genkit-dart/references/genkit_openai.md": "bc5407afcdcb2112143bce011bb24e45",
".agents/skills/developing-genkit-dart/references/genkit_anthropic.md": "12630eaa5ad87c085351756c1f8938e1",
".agents/skills/developing-genkit-dart/references/genkit_chrome.md": "a8043be369a7c05b369729ee6dc5ddad",
".agents/skills/developing-genkit-dart/references/genkit.md": "deaf2e56607e9bc3f8eb32aa6f84af5b",
".agents/skills/developing-genkit-dart/references/genkit_mcp.md": "94ff31e1c8571dec350a080fc94eaf2c",
".agents/skills/developing-genkit-dart/references/genkit_firebase_ai.md": "189c26ff03ad77b1191d84cfda77a9db",
".agents/skills/developing-genkit-dart/references/genkit_middleware.md": "aafbb8d12c4f849f1e1806876aaebe75",
".agents/skills/developing-genkit-dart/references/schemantic.md": "cfd0520eda8c2b6d0af6b0060f7ecc55",
".agents/skills/developing-genkit-dart/references/genkit_google_genai.md": "690be0653e609793794ca22fcdc791b0",
".agents/skills/developing-genkit-dart/references/genkit_shelf.md": "b20a83cc8de2b0657a18a3a68d480c60",
".agents/skills/developing-genkit-dart/SKILL.md": "ebfaf7d812d806c631c44fde9b1ef4f1",
".agents/skills/firebase-ai-logic/references/usage_patterns_web.md": "f2c0b2fafdb245d1b4080d1e35f1bc6a",
".agents/skills/firebase-ai-logic/SKILL.md": "74b2bc1d7d79015f64e1a287f81a72f6",
".agents/skills/developing-genkit-js/references/examples.md": "092da105d98d8a5c6c05ff56398d3982",
".agents/skills/developing-genkit-js/references/docs-and-cli.md": "ab846bfdd85cacb342d1b0169d483865",
".agents/skills/developing-genkit-js/references/best-practices.md": "392b2e0f2ef112015f5b4300ee3f4ae9",
".agents/skills/developing-genkit-js/references/setup.md": "7c38adc407e824a8c89319823e5e746a",
".agents/skills/developing-genkit-js/references/common-errors.md": "fe379498c5d4a8a1b055bfa5ebc547fd",
".agents/skills/developing-genkit-js/SKILL.md": "64329f401eb0ba58fc736ffd6a67320f",
".agents/skills/firebase-hosting-basics/references/deploying.md": "c729a6ecfed24994501fecb9e2d65f73",
".agents/skills/firebase-hosting-basics/references/configuration.md": "f02657bc397346896bab1cb0ec61edec",
".agents/skills/firebase-hosting-basics/SKILL.md": "d68eccf43abd95ffc97ef8dfac7bbe33",
".agents/skills/firebase-basics/references/firebase-project-create.md": "2633b3a78863b755d8bb96cf7158db99",
".agents/skills/firebase-basics/references/local-env-setup.md": "b57788cb7b69d05e554c0f5cfb717952",
".agents/skills/firebase-basics/references/firebase-service-init.md": "963e169bd9e79b5b3ec7e520d696a67c",
".agents/skills/firebase-basics/references/setup-claude_code.md": "ecf90f4beb94b2ed277fd553fb488d7d",
".agents/skills/firebase-basics/references/refresh-gemini-cli.md": "cd2e2a90b206fd2aedda7700d6568b7e",
".agents/skills/firebase-basics/references/setup-gemini_cli.md": "67e034ce5c454ec4773e7af43c579f2b",
".agents/skills/firebase-basics/references/setup-antigravity.md": "4173e2d583ace5b54453df4b988639c7",
".agents/skills/firebase-basics/references/web_setup.md": "cd40536c4af35dbe92e930d82e0e49e1",
".agents/skills/firebase-basics/references/setup-cursor.md": "887433a0a4b2eedf3f5f6113a695bcfe",
".agents/skills/firebase-basics/references/refresh-antigravity.md": "6cd3121a97824ef97331f200a1f46c1c",
".agents/skills/firebase-basics/references/setup-other_agents.md": "e40942687ca209227a04735b7e67dd88",
".agents/skills/firebase-basics/references/firebase-cli-guide.md": "cdb71fc2ab3e166bcd5374b0b284eb4d",
".agents/skills/firebase-basics/references/setup-github_copilot.md": "0ab1a0d4d0b3ea929fe4830afaf83bd8",
".agents/skills/firebase-basics/references/refresh-other-agents.md": "24706a04fd79d32044cc8fe8b2fb524b",
".agents/skills/firebase-basics/references/refresh-claude.md": "823dcb8fc4e9c3be0821ab3a3008fb68",
".agents/skills/firebase-basics/SKILL.md": "f5058766c00317b4155eb52e7c7b52c2",
".agents/skills/firebase-firestore-enterprise-native-mode/references/data_model.md": "8a3a35044dcfdfb105125cee732936b0",
".agents/skills/firebase-firestore-enterprise-native-mode/references/python_sdk_usage.md": "38e46e23155c4b5d41a2d18714df2d5d",
".agents/skills/firebase-firestore-enterprise-native-mode/references/indexes.md": "ef83b8f336311d33240d8a2fcf5a4069",
".agents/skills/firebase-firestore-enterprise-native-mode/references/provisioning.md": "1b8cf19e2eb043fdf091dd69a379e4bf",
".agents/skills/firebase-firestore-enterprise-native-mode/references/web_sdk_usage.md": "ada015e12d16d938b1cc00c3e489f185",
".agents/skills/firebase-firestore-enterprise-native-mode/references/security_rules.md": "2252c5c669eba024bd9b86777ba7f26d",
".agents/skills/firebase-firestore-enterprise-native-mode/SKILL.md": "a385c3ec4f8e62be9e6070296472e2a2",
".agents/skills/firebase-firestore-standard/references/indexes.md": "d16a84be8ece7528b44325942aa0167f",
".agents/skills/firebase-firestore-standard/references/provisioning.md": "d841b670e3bc4514fc66b1a5ad78b9e7",
".agents/skills/firebase-firestore-standard/references/web_sdk_usage.md": "47b48a8a6168c307766ccf433ee4d70f",
".agents/skills/firebase-firestore-standard/references/security_rules.md": "2252c5c669eba024bd9b86777ba7f26d",
".agents/skills/firebase-firestore-standard/SKILL.md": "ae02b05be09d28d74a72730898a3eaf7",
".agents/skills/firestore-security-rules-auditor/SKILL.md": "e5143fa6159dd9bb3a2bb070f511a819",
".agents/skills/firebase-data-connect/examples.md": "15489d766e38cd2979ec4342fb51dac2",
".agents/skills/firebase-data-connect/templates.md": "9b84da67c76c8a3ba2e85b7cb4e937c1",
".agents/skills/firebase-data-connect/SKILL.md": "201e9d7007f2f1bc1bbb3b85b7bb2403",
".agents/skills/firebase-data-connect/reference/operations.md": "9f1d49a1dca75decd0779ab9b0f937a8",
".agents/skills/firebase-data-connect/reference/schema.md": "4a2b27b00d6093bad0ca2d757fc5a1d3",
".agents/skills/firebase-data-connect/reference/config.md": "3ac7e1ffd7bbd84ab4f27eda76d2d26a",
".agents/skills/firebase-data-connect/reference/sdks.md": "7edb114b8ff9d8af455e113ca9dc7e6d",
".agents/skills/firebase-data-connect/reference/advanced.md": "24fe4678fb0f86d89dea91717708e81f",
".agents/skills/firebase-data-connect/reference/security.md": "603f276cd9e8336aac22e31a833e671b",
".agents/skills/firebase-app-hosting-basics/references/configuration.md": "3d07374b336c68b918856aabd47c4259",
".agents/skills/firebase-app-hosting-basics/references/cli_commands.md": "0403657158d488bf24cbd63f32621109",
".agents/skills/firebase-app-hosting-basics/references/emulation.md": "b260bc0b9d5ae868ca316edfb61f2cf0",
".agents/skills/firebase-app-hosting-basics/SKILL.md": "50f1149b54724ca251f74f61eb380abf",
".claude/skills/developing-genkit-go/references/providers.md": "94becc597b1f53fded34d38e61679a6c",
".claude/skills/developing-genkit-go/references/flows-and-http.md": "b7dede1526f535cf99fb638b17c820e8",
".claude/skills/developing-genkit-go/references/getting-started.md": "1333864b7cbce4ab8696d44860ac52da",
".claude/skills/developing-genkit-go/references/generation.md": "4b7fc8e220157abbe5912faa021d3860",
".claude/skills/developing-genkit-go/references/prompts.md": "65e26a3d263a3e7a12d45b0a4680ff81",
".claude/skills/developing-genkit-go/references/tools.md": "aac61ff499acfd348f693240ce641231",
".claude/skills/developing-genkit-go/SKILL.md": "81e9c40e9c15dfd4cdbc873663ecd782",
".claude/skills/firebase-auth-basics/references/client_sdk_web.md": "f31721854ba740d8ce04d550e1af8b4f",
".claude/skills/firebase-auth-basics/references/security_rules.md": "825de231c117fdc362581e8738283310",
".claude/skills/firebase-auth-basics/SKILL.md": "cc98edf7a721e34e37ea73d5f58ac391",
".claude/skills/developing-genkit-dart/references/genkit_openai.md": "bc5407afcdcb2112143bce011bb24e45",
".claude/skills/developing-genkit-dart/references/genkit_anthropic.md": "12630eaa5ad87c085351756c1f8938e1",
".claude/skills/developing-genkit-dart/references/genkit_chrome.md": "a8043be369a7c05b369729ee6dc5ddad",
".claude/skills/developing-genkit-dart/references/genkit.md": "deaf2e56607e9bc3f8eb32aa6f84af5b",
".claude/skills/developing-genkit-dart/references/genkit_mcp.md": "94ff31e1c8571dec350a080fc94eaf2c",
".claude/skills/developing-genkit-dart/references/genkit_firebase_ai.md": "189c26ff03ad77b1191d84cfda77a9db",
".claude/skills/developing-genkit-dart/references/genkit_middleware.md": "aafbb8d12c4f849f1e1806876aaebe75",
".claude/skills/developing-genkit-dart/references/schemantic.md": "cfd0520eda8c2b6d0af6b0060f7ecc55",
".claude/skills/developing-genkit-dart/references/genkit_google_genai.md": "690be0653e609793794ca22fcdc791b0",
".claude/skills/developing-genkit-dart/references/genkit_shelf.md": "b20a83cc8de2b0657a18a3a68d480c60",
".claude/skills/developing-genkit-dart/SKILL.md": "ebfaf7d812d806c631c44fde9b1ef4f1",
".claude/skills/firebase-ai-logic/references/usage_patterns_web.md": "f2c0b2fafdb245d1b4080d1e35f1bc6a",
".claude/skills/firebase-ai-logic/SKILL.md": "74b2bc1d7d79015f64e1a287f81a72f6",
".claude/skills/developing-genkit-js/references/examples.md": "092da105d98d8a5c6c05ff56398d3982",
".claude/skills/developing-genkit-js/references/docs-and-cli.md": "ab846bfdd85cacb342d1b0169d483865",
".claude/skills/developing-genkit-js/references/best-practices.md": "392b2e0f2ef112015f5b4300ee3f4ae9",
".claude/skills/developing-genkit-js/references/setup.md": "7c38adc407e824a8c89319823e5e746a",
".claude/skills/developing-genkit-js/references/common-errors.md": "fe379498c5d4a8a1b055bfa5ebc547fd",
".claude/skills/developing-genkit-js/SKILL.md": "64329f401eb0ba58fc736ffd6a67320f",
".claude/skills/firebase-hosting-basics/references/deploying.md": "c729a6ecfed24994501fecb9e2d65f73",
".claude/skills/firebase-hosting-basics/references/configuration.md": "f02657bc397346896bab1cb0ec61edec",
".claude/skills/firebase-hosting-basics/SKILL.md": "d68eccf43abd95ffc97ef8dfac7bbe33",
".claude/skills/firebase-basics/references/firebase-project-create.md": "2633b3a78863b755d8bb96cf7158db99",
".claude/skills/firebase-basics/references/local-env-setup.md": "b57788cb7b69d05e554c0f5cfb717952",
".claude/skills/firebase-basics/references/firebase-service-init.md": "963e169bd9e79b5b3ec7e520d696a67c",
".claude/skills/firebase-basics/references/setup-claude_code.md": "ecf90f4beb94b2ed277fd553fb488d7d",
".claude/skills/firebase-basics/references/refresh-gemini-cli.md": "cd2e2a90b206fd2aedda7700d6568b7e",
".claude/skills/firebase-basics/references/setup-gemini_cli.md": "67e034ce5c454ec4773e7af43c579f2b",
".claude/skills/firebase-basics/references/setup-antigravity.md": "4173e2d583ace5b54453df4b988639c7",
".claude/skills/firebase-basics/references/web_setup.md": "cd40536c4af35dbe92e930d82e0e49e1",
".claude/skills/firebase-basics/references/setup-cursor.md": "887433a0a4b2eedf3f5f6113a695bcfe",
".claude/skills/firebase-basics/references/refresh-antigravity.md": "6cd3121a97824ef97331f200a1f46c1c",
".claude/skills/firebase-basics/references/setup-other_agents.md": "e40942687ca209227a04735b7e67dd88",
".claude/skills/firebase-basics/references/firebase-cli-guide.md": "cdb71fc2ab3e166bcd5374b0b284eb4d",
".claude/skills/firebase-basics/references/setup-github_copilot.md": "0ab1a0d4d0b3ea929fe4830afaf83bd8",
".claude/skills/firebase-basics/references/refresh-other-agents.md": "24706a04fd79d32044cc8fe8b2fb524b",
".claude/skills/firebase-basics/references/refresh-claude.md": "823dcb8fc4e9c3be0821ab3a3008fb68",
".claude/skills/firebase-basics/SKILL.md": "f5058766c00317b4155eb52e7c7b52c2",
".claude/skills/firebase-firestore-enterprise-native-mode/references/data_model.md": "8a3a35044dcfdfb105125cee732936b0",
".claude/skills/firebase-firestore-enterprise-native-mode/references/python_sdk_usage.md": "38e46e23155c4b5d41a2d18714df2d5d",
".claude/skills/firebase-firestore-enterprise-native-mode/references/indexes.md": "ef83b8f336311d33240d8a2fcf5a4069",
".claude/skills/firebase-firestore-enterprise-native-mode/references/provisioning.md": "1b8cf19e2eb043fdf091dd69a379e4bf",
".claude/skills/firebase-firestore-enterprise-native-mode/references/web_sdk_usage.md": "ada015e12d16d938b1cc00c3e489f185",
".claude/skills/firebase-firestore-enterprise-native-mode/references/security_rules.md": "2252c5c669eba024bd9b86777ba7f26d",
".claude/skills/firebase-firestore-enterprise-native-mode/SKILL.md": "a385c3ec4f8e62be9e6070296472e2a2",
".claude/skills/firebase-firestore-standard/references/indexes.md": "d16a84be8ece7528b44325942aa0167f",
".claude/skills/firebase-firestore-standard/references/provisioning.md": "d841b670e3bc4514fc66b1a5ad78b9e7",
".claude/skills/firebase-firestore-standard/references/web_sdk_usage.md": "47b48a8a6168c307766ccf433ee4d70f",
".claude/skills/firebase-firestore-standard/references/security_rules.md": "2252c5c669eba024bd9b86777ba7f26d",
".claude/skills/firebase-firestore-standard/SKILL.md": "ae02b05be09d28d74a72730898a3eaf7",
".claude/skills/firestore-security-rules-auditor/SKILL.md": "e5143fa6159dd9bb3a2bb070f511a819",
".claude/skills/firebase-data-connect/examples.md": "15489d766e38cd2979ec4342fb51dac2",
".claude/skills/firebase-data-connect/templates.md": "9b84da67c76c8a3ba2e85b7cb4e937c1",
".claude/skills/firebase-data-connect/SKILL.md": "201e9d7007f2f1bc1bbb3b85b7bb2403",
".claude/skills/firebase-data-connect/reference/operations.md": "9f1d49a1dca75decd0779ab9b0f937a8",
".claude/skills/firebase-data-connect/reference/schema.md": "4a2b27b00d6093bad0ca2d757fc5a1d3",
".claude/skills/firebase-data-connect/reference/config.md": "3ac7e1ffd7bbd84ab4f27eda76d2d26a",
".claude/skills/firebase-data-connect/reference/sdks.md": "7edb114b8ff9d8af455e113ca9dc7e6d",
".claude/skills/firebase-data-connect/reference/advanced.md": "24fe4678fb0f86d89dea91717708e81f",
".claude/skills/firebase-data-connect/reference/security.md": "603f276cd9e8336aac22e31a833e671b",
".claude/skills/firebase-app-hosting-basics/references/configuration.md": "3d07374b336c68b918856aabd47c4259",
".claude/skills/firebase-app-hosting-basics/references/cli_commands.md": "0403657158d488bf24cbd63f32621109",
".claude/skills/firebase-app-hosting-basics/references/emulation.md": "b260bc0b9d5ae868ca316edfb61f2cf0",
".claude/skills/firebase-app-hosting-basics/SKILL.md": "50f1149b54724ca251f74f61eb380abf",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"n/index.html": "b3b3380b0c44850a21c18659055d3c42",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
".kilocode/skills/developing-genkit-go/references/providers.md": "94becc597b1f53fded34d38e61679a6c",
".kilocode/skills/developing-genkit-go/references/flows-and-http.md": "b7dede1526f535cf99fb638b17c820e8",
".kilocode/skills/developing-genkit-go/references/getting-started.md": "1333864b7cbce4ab8696d44860ac52da",
".kilocode/skills/developing-genkit-go/references/generation.md": "4b7fc8e220157abbe5912faa021d3860",
".kilocode/skills/developing-genkit-go/references/prompts.md": "65e26a3d263a3e7a12d45b0a4680ff81",
".kilocode/skills/developing-genkit-go/references/tools.md": "aac61ff499acfd348f693240ce641231",
".kilocode/skills/developing-genkit-go/SKILL.md": "81e9c40e9c15dfd4cdbc873663ecd782",
".kilocode/skills/firebase-auth-basics/references/client_sdk_web.md": "f31721854ba740d8ce04d550e1af8b4f",
".kilocode/skills/firebase-auth-basics/references/security_rules.md": "825de231c117fdc362581e8738283310",
".kilocode/skills/firebase-auth-basics/SKILL.md": "cc98edf7a721e34e37ea73d5f58ac391",
".kilocode/skills/developing-genkit-dart/references/genkit_openai.md": "bc5407afcdcb2112143bce011bb24e45",
".kilocode/skills/developing-genkit-dart/references/genkit_anthropic.md": "12630eaa5ad87c085351756c1f8938e1",
".kilocode/skills/developing-genkit-dart/references/genkit_chrome.md": "a8043be369a7c05b369729ee6dc5ddad",
".kilocode/skills/developing-genkit-dart/references/genkit.md": "deaf2e56607e9bc3f8eb32aa6f84af5b",
".kilocode/skills/developing-genkit-dart/references/genkit_mcp.md": "94ff31e1c8571dec350a080fc94eaf2c",
".kilocode/skills/developing-genkit-dart/references/genkit_firebase_ai.md": "189c26ff03ad77b1191d84cfda77a9db",
".kilocode/skills/developing-genkit-dart/references/genkit_middleware.md": "aafbb8d12c4f849f1e1806876aaebe75",
".kilocode/skills/developing-genkit-dart/references/schemantic.md": "cfd0520eda8c2b6d0af6b0060f7ecc55",
".kilocode/skills/developing-genkit-dart/references/genkit_google_genai.md": "690be0653e609793794ca22fcdc791b0",
".kilocode/skills/developing-genkit-dart/references/genkit_shelf.md": "b20a83cc8de2b0657a18a3a68d480c60",
".kilocode/skills/developing-genkit-dart/SKILL.md": "ebfaf7d812d806c631c44fde9b1ef4f1",
".kilocode/skills/firebase-ai-logic/references/usage_patterns_web.md": "f2c0b2fafdb245d1b4080d1e35f1bc6a",
".kilocode/skills/firebase-ai-logic/SKILL.md": "74b2bc1d7d79015f64e1a287f81a72f6",
".kilocode/skills/developing-genkit-js/references/examples.md": "092da105d98d8a5c6c05ff56398d3982",
".kilocode/skills/developing-genkit-js/references/docs-and-cli.md": "ab846bfdd85cacb342d1b0169d483865",
".kilocode/skills/developing-genkit-js/references/best-practices.md": "392b2e0f2ef112015f5b4300ee3f4ae9",
".kilocode/skills/developing-genkit-js/references/setup.md": "7c38adc407e824a8c89319823e5e746a",
".kilocode/skills/developing-genkit-js/references/common-errors.md": "fe379498c5d4a8a1b055bfa5ebc547fd",
".kilocode/skills/developing-genkit-js/SKILL.md": "64329f401eb0ba58fc736ffd6a67320f",
".kilocode/skills/firebase-hosting-basics/references/deploying.md": "c729a6ecfed24994501fecb9e2d65f73",
".kilocode/skills/firebase-hosting-basics/references/configuration.md": "f02657bc397346896bab1cb0ec61edec",
".kilocode/skills/firebase-hosting-basics/SKILL.md": "d68eccf43abd95ffc97ef8dfac7bbe33",
".kilocode/skills/firebase-basics/references/firebase-project-create.md": "2633b3a78863b755d8bb96cf7158db99",
".kilocode/skills/firebase-basics/references/local-env-setup.md": "b57788cb7b69d05e554c0f5cfb717952",
".kilocode/skills/firebase-basics/references/firebase-service-init.md": "963e169bd9e79b5b3ec7e520d696a67c",
".kilocode/skills/firebase-basics/references/setup-claude_code.md": "ecf90f4beb94b2ed277fd553fb488d7d",
".kilocode/skills/firebase-basics/references/refresh-gemini-cli.md": "cd2e2a90b206fd2aedda7700d6568b7e",
".kilocode/skills/firebase-basics/references/setup-gemini_cli.md": "67e034ce5c454ec4773e7af43c579f2b",
".kilocode/skills/firebase-basics/references/setup-antigravity.md": "4173e2d583ace5b54453df4b988639c7",
".kilocode/skills/firebase-basics/references/web_setup.md": "cd40536c4af35dbe92e930d82e0e49e1",
".kilocode/skills/firebase-basics/references/setup-cursor.md": "887433a0a4b2eedf3f5f6113a695bcfe",
".kilocode/skills/firebase-basics/references/refresh-antigravity.md": "6cd3121a97824ef97331f200a1f46c1c",
".kilocode/skills/firebase-basics/references/setup-other_agents.md": "e40942687ca209227a04735b7e67dd88",
".kilocode/skills/firebase-basics/references/firebase-cli-guide.md": "cdb71fc2ab3e166bcd5374b0b284eb4d",
".kilocode/skills/firebase-basics/references/setup-github_copilot.md": "0ab1a0d4d0b3ea929fe4830afaf83bd8",
".kilocode/skills/firebase-basics/references/refresh-other-agents.md": "24706a04fd79d32044cc8fe8b2fb524b",
".kilocode/skills/firebase-basics/references/refresh-claude.md": "823dcb8fc4e9c3be0821ab3a3008fb68",
".kilocode/skills/firebase-basics/SKILL.md": "f5058766c00317b4155eb52e7c7b52c2",
".kilocode/skills/firebase-firestore-enterprise-native-mode/references/data_model.md": "8a3a35044dcfdfb105125cee732936b0",
".kilocode/skills/firebase-firestore-enterprise-native-mode/references/python_sdk_usage.md": "38e46e23155c4b5d41a2d18714df2d5d",
".kilocode/skills/firebase-firestore-enterprise-native-mode/references/indexes.md": "ef83b8f336311d33240d8a2fcf5a4069",
".kilocode/skills/firebase-firestore-enterprise-native-mode/references/provisioning.md": "1b8cf19e2eb043fdf091dd69a379e4bf",
".kilocode/skills/firebase-firestore-enterprise-native-mode/references/web_sdk_usage.md": "ada015e12d16d938b1cc00c3e489f185",
".kilocode/skills/firebase-firestore-enterprise-native-mode/references/security_rules.md": "2252c5c669eba024bd9b86777ba7f26d",
".kilocode/skills/firebase-firestore-enterprise-native-mode/SKILL.md": "a385c3ec4f8e62be9e6070296472e2a2",
".kilocode/skills/firebase-firestore-standard/references/indexes.md": "d16a84be8ece7528b44325942aa0167f",
".kilocode/skills/firebase-firestore-standard/references/provisioning.md": "d841b670e3bc4514fc66b1a5ad78b9e7",
".kilocode/skills/firebase-firestore-standard/references/web_sdk_usage.md": "47b48a8a6168c307766ccf433ee4d70f",
".kilocode/skills/firebase-firestore-standard/references/security_rules.md": "2252c5c669eba024bd9b86777ba7f26d",
".kilocode/skills/firebase-firestore-standard/SKILL.md": "ae02b05be09d28d74a72730898a3eaf7",
".kilocode/skills/firestore-security-rules-auditor/SKILL.md": "e5143fa6159dd9bb3a2bb070f511a819",
".kilocode/skills/firebase-data-connect/examples.md": "15489d766e38cd2979ec4342fb51dac2",
".kilocode/skills/firebase-data-connect/templates.md": "9b84da67c76c8a3ba2e85b7cb4e937c1",
".kilocode/skills/firebase-data-connect/SKILL.md": "201e9d7007f2f1bc1bbb3b85b7bb2403",
".kilocode/skills/firebase-data-connect/reference/operations.md": "9f1d49a1dca75decd0779ab9b0f937a8",
".kilocode/skills/firebase-data-connect/reference/schema.md": "4a2b27b00d6093bad0ca2d757fc5a1d3",
".kilocode/skills/firebase-data-connect/reference/config.md": "3ac7e1ffd7bbd84ab4f27eda76d2d26a",
".kilocode/skills/firebase-data-connect/reference/sdks.md": "7edb114b8ff9d8af455e113ca9dc7e6d",
".kilocode/skills/firebase-data-connect/reference/advanced.md": "24fe4678fb0f86d89dea91717708e81f",
".kilocode/skills/firebase-data-connect/reference/security.md": "603f276cd9e8336aac22e31a833e671b",
".kilocode/skills/firebase-app-hosting-basics/references/configuration.md": "3d07374b336c68b918856aabd47c4259",
".kilocode/skills/firebase-app-hosting-basics/references/cli_commands.md": "0403657158d488bf24cbd63f32621109",
".kilocode/skills/firebase-app-hosting-basics/references/emulation.md": "b260bc0b9d5ae868ca316edfb61f2cf0",
".kilocode/skills/firebase-app-hosting-basics/SKILL.md": "50f1149b54724ca251f74f61eb380abf",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "d37c4da88379fe0a558eae1a785147b2",
"firebase.json": "a9c906a1fcaf0bb9acfade00b6047374",
"assets/AssetManifest.json": "ea66be726abc225e92ac802d1f12856a",
"assets/NOTICES": "4f5d9081e21a053449534c393bda9cb5",
"assets/FontManifest.json": "2a3f09429db12146b660976774660777",
"assets/AssetManifest.bin.json": "94770df6ee426825ac5e16b2687ed5b6",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Regular-400.otf": "8d0acfbf774979914d3c0d736f4be13e",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Brands-Regular-400.otf": "27a4ced4c6de08cab47b05d8d388d4b3",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Solid-900.otf": "108513107eb84f9947daa89d14368bd2",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "d07a484f96dc04efe00fb7dc5dae99d5",
"assets/fonts/MaterialIcons-Regular.otf": "7a657853c5cc4b21fcb2e295ff38dc38",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
