# APOSTILA COMPLETA - MEU PRIMEIRO JOGO GODOT
## Análise Detalhada do Projeto de Plataforma 2D

---

## ÍNDICE
1. [Visão Geral do Projeto](#visão-geral-do-projeto)
2. [Configuração do Projeto](#configuração-do-projeto)
3. [Sistema do Player](#sistema-do-player)
4. [Sistema de Fall Zone](#sistema-de-fall-zone)
5. [Estrutura das Cenas](#estrutura-das-cenas)
6. [Sistema de Parallax](#sistema-de-parallax)
7. [Sistema de TileMap](#sistema-de-tilemap)
8. [Conceitos Fundamentais Aplicados](#conceitos-fundamentais-aplicados)

---

## VISÃO GERAL DO PROJETO

Este é um jogo de plataforma 2D desenvolvido em Godot 3.x que implementa:
- **Movimento de personagem** com física realista
- **Sistema de pulo** com detecção de chão
- **Animações** baseadas em estados
- **Parallax scrolling** para profundidade visual
- **Sistema de respawn** com fall zones
- **Câmera** que segue o jogador

### Arquitetura do Projeto
```
meu-primeiro-jogo-sab-10h2/
├── project.godot          # Configurações principais
├── levels/
│   └── Level_01.tscn     # Cena principal do jogo
├── scenes/
│   ├── Player.tscn       # Cena do jogador
│   └── PlayerOld.tscn    # Versão anterior (backup)
├── scripts/
│   ├── Player.gd         # Lógica do jogador
│   └── fall-zone.gd      # Sistema de respawn
└── assets/               # Recursos visuais
```

---

## CONFIGURAÇÃO DO PROJETO

### Arquivo: `project.godot`

#### **Linhas 1-8: Cabeçalho do Projeto**
```ini
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=4
```
**Explicação:** Define que este é um projeto Godot 3.x (config_version=4).

#### **Linhas 10-14: Configurações da Aplicação**
```ini
[application]

config/name="meu-primeiro-jogo-sab-10h2"
run/main_scene="res://levels/Level_01.tscn"
config/icon="res://icon.png"
```
**Explicação:**
- `config/name`: Nome do projeto
- `run/main_scene`: Cena que será carregada ao iniciar o jogo
- `config/icon`: Ícone do executável

#### **Linhas 16-23: Configurações de Display**
```ini
[display]

window/size/width=320
window/size/height=192
window/size/test_width=640
window/size/test_height=384
window/stretch/mode="2d"
window/stretch/aspect="keep"
```
**Explicação:**
- **Resolução base:** 320x192 (estilo pixel art retro)
- **Resolução de teste:** 640x384 (2x maior para visualização)
- **Modo de stretch:** "2d" mantém proporções dos pixels
- **Aspecto:** "keep" preserva a proporção original

#### **Linhas 45-58: Controles de Input**
```ini
[input]

move_left={
"deadzone": 0.5,
"events": [ Object(InputEventKey,"scancode":65), Object(InputEventKey,"scancode":16777231) ]
}
move_right={
"deadzone": 0.5,
"events": [ Object(InputEventKey,"scancode":68), Object(InputEventKey,"scancode":16777233) ]
}
jump={
"deadzone": 0.5,
"events": [ Object(InputEventKey,"scancode":32) ]
}
```
**Explicação:**
- **move_left:** Teclas A (scancode 65) e Seta Esquerda (16777231)
- **move_right:** Teclas D (scancode 68) e Seta Direita (16777233)
- **jump:** Tecla Espaço (scancode 32)
- **deadzone:** Zona morta para controles analógicos

#### **Linhas 60-65: Camadas de Física**
```ini
[layer_names]

2d_physics/layer_1="Player"
2d_physics/layer_2="Enemies"
2d_physics/layer_3="Items"
2d_physics/layer_4="World"
```
**Explicação:** Define nomes para as camadas de colisão, facilitando a organização.

---

## SISTEMA DO PLAYER

### Arquivo: `scripts/Player.gd`

#### **Linha 1: Herança da Classe**
```gdscript
extends KinematicBody2D
```
**Explicação:** O player herda de KinematicBody2D, que é ideal para personagens controláveis com física customizada.

#### **Linhas 3-8: Variáveis de Estado**
```gdscript
var velocity = Vector2.ZERO
var move_speed = 850
var gravity = 1200
var jump_force = -720
var is_grounded
```
**Explicação:**
- `velocity`: Vetor de velocidade (x=horizontal, y=vertical)
- `move_speed`: Velocidade de movimento horizontal (850 pixels/segundo)
- `gravity`: Força da gravidade (1200 pixels/segundo²)
- `jump_force`: Força do pulo (-720 = para cima)
- `is_grounded`: Boolean que indica se está no chão

#### **Linha 10: Referência aos RayCasts**
```gdscript
onready var raycasts = $raycasts
```
**Explicação:** Obtém referência ao nó que contém os RayCasts para detecção de chão.

#### **Linhas 12-22: Loop Principal de Física**
```gdscript
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	_get_input()
	
	velocity = move_and_slide(velocity)
	
	is_grounded = _check_is_ground()
	
	_set_animation()
	
#	print(velocity.y)
```
**Explicação:**
1. **Linha 13:** Aplica gravidade constantemente
2. **Linha 15:** Processa input do jogador
3. **Linha 17:** Move o personagem usando a física do Godot
4. **Linha 19:** Verifica se está tocando o chão
5. **Linha 21:** Atualiza as animações
6. **Linha 23:** Debug comentado da velocidade Y

#### **Linhas 24-32: Sistema de Input**
```gdscript
func _get_input():
	velocity.x = 0
	var move_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, 0.2)
	
	if move_direction != 0:
		$texture.scale.x = move_direction
```
**Explicação:**
- **Linha 25:** Zera velocidade horizontal
- **Linha 26:** Calcula direção (-1=esquerda, 0=parado, 1=direita)
- **Linha 27:** Aplica interpolação suave (lerp) para movimento fluido
- **Linhas 29-30:** Inverte sprite baseado na direção

#### **Linhas 34-37: Sistema de Pulo**
```gdscript
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") && is_grounded:
		velocity.y = jump_force / 2
```
**Explicação:**
- Usa `_input()` para capturar eventos únicos (não contínuos)
- Só permite pulo se estiver no chão
- Divide jump_force por 2 para ajustar altura

#### **Linhas 39-44: Detecção de Chão**
```gdscript
func _check_is_ground():
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	return false
```
**Explicação:**
- Itera por todos os RayCasts filhos
- Se qualquer um detectar colisão, retorna true
- Permite detecção precisa em bordas e slopes

#### **Linhas 46-57: Sistema de Animações**
```gdscript
func _set_animation():
	var anim = "idle"
	
	if !is_grounded:
		anim = "jump"
		
	elif velocity.x != 0:
		anim = "run"
		
	if $anim.assigned_animation != anim:
		$anim.play(anim)
```
**Explicação:**
- **Prioridade 1:** Se não está no chão → "jump"
- **Prioridade 2:** Se está se movendo → "run"
- **Padrão:** "idle"
- Só muda animação se for diferente da atual (otimização)

---

## SISTEMA DE FALL ZONE

### Arquivo: `scripts/fall-zone.gd`

#### **Linha 1: Herança da Classe**
```gdscript
extends Area2D
```
**Explicação:** Area2D é ideal para detectar quando objetos entram/saem de uma área.

#### **Linhas 4-6: Função de Callback**
```gdscript
func _on_fallzone_body_entered(body: Node) -> void:
	print(body.name)
	get_tree().reload_current_scene()
```
**Explicação:**
- **Linha 5:** Debug - mostra nome do objeto que entrou
- **Linha 6:** Recarrega a cena atual (respawn)

---

## ESTRUTURA DAS CENAS

### Cena do Player (`scenes/Player.tscn`)

#### **Hierarquia de Nós:**
```
Player (KinematicBody2D)
├── texture (Sprite)           # Visual do personagem
├── collision (CollisionShape2D) # Hitbox física
├── anim (AnimationPlayer)     # Controlador de animações
├── raycasts (Node2D)         # Container dos raycasts
│   ├── raycast (RayCast2D)   # Detecção esquerda
│   └── raycast2 (RayCast2D)  # Detecção direita
└── camera (Camera2D)         # Câmera que segue o player
```

#### **Configurações da Câmera:**
```
current = true                 # Câmera ativa
limit_left = 0                # Limite esquerdo
limit_bottom = 400            # Limite inferior
limit_smoothed = true         # Movimento suave
drag_margin_left = 0.4        # Margem de arrasto
drag_margin_right = 0.4       # Margem de arrasto
```

#### **Sistema de Animações:**
- **idle:** 10 frames, loop infinito
- **run:** 10 frames, loop infinito
- **jump:** 2 frames (frame 0 = subindo)
- **fall:** 2 frames (frame 1 = descendo)
- **hit:** Frame único para dano

### Cena Principal (`levels/Level_01.tscn`)

#### **Hierarquia de Nós:**
```
Level_01 (Node2D)
├── Player (instância de Player.tscn)
├── TileMap (TileMap)          # Plataformas e cenário
├── ParallaxBackground         # Sistema de parallax
│   ├── sky (ParallaxLayer)
│   ├── clouds (ParallaxLayer)
│   ├── cloud-mountain (ParallaxLayer)
│   ├── mountain-trees (ParallaxLayer)
│   └── trees (ParallaxLayer)
├── fall-zone (Area2D)         # Zona de morte 1
└── fall-zone2 (Area2D)        # Zona de morte 2
```

---

## SISTEMA DE PARALLAX

### **Conceito:**
Parallax scrolling cria ilusão de profundidade movendo camadas em velocidades diferentes.

### **Configuração das Camadas:**

#### **Sky (Fundo):**
```
motion_mirroring = Vector2(576, 208)  # Repetição
motion_scale = Vector2(1, 1)          # Velocidade padrão
```

#### **Clouds (Nuvens):**
```
motion_mirroring = Vector2(576, 0)    # Repetição horizontal
Shader animado para movimento automático
```

#### **Cloud-Mountain:**
```
motion_scale = Vector2(0.4, 0.8)      # 40% da velocidade
motion_mirroring = Vector2(576, 0)
```

#### **Mountain-Trees:**
```
motion_scale = Vector2(0.6, 1)        # 60% da velocidade
motion_mirroring = Vector2(576, 0)
```

#### **Trees (Primeiro Plano):**
```
motion_scale = Vector2(0.8, 1)        # 80% da velocidade
motion_mirroring = Vector2(576, 0)
```

### **Shader das Nuvens:**
```glsl
shader_type canvas_item;

uniform vec2 Direction = vec2(1.0,0.0);
uniform float Speed = 0.02f;

void fragment()
{
    COLOR = texture(TEXTURE, UV + (Direction * TIME * Speed));
}
```
**Explicação:** Move a textura automaticamente baseado no tempo.

---

## SISTEMA DE TILEMAP

### **Configuração:**
- **Cell Size:** 16x16 pixels
- **29 tiles diferentes** configurados
- **Colisões automáticas** para cada tile
- **One-way platforms** (tiles 14, 26, 27, 28)

### **Tipos de Tiles:**
- **0-8:** Tiles básicos de terreno
- **9-18:** Texturas decorativas
- **19:** Tile decorativo sem colisão
- **20-28:** Tiles de terreno avançados
- **29:** Tile decorativo sem colisão

### **One-Way Platforms:**
```
shape_one_way = true
shape_one_way_margin = 1.0
```
Permite pular através de baixo, mas bloqueia queda.

---

## CONCEITOS FUNDAMENTAIS APLICADOS

### **1. Física de Movimento:**
- **Gravidade constante:** `velocity.y += gravity * delta`
- **Interpolação suave:** `lerp(velocity.x, target, 0.2)`
- **Delta time:** Garante movimento consistente independente do FPS

### **2. Detecção de Colisão:**
- **KinematicBody2D:** Para personagens controláveis
- **Area2D:** Para triggers e zonas especiais
- **RayCast2D:** Para detecção precisa de chão

### **3. Sistema de Estados:**
- **Estado baseado em condições:** is_grounded, velocity.x
- **Prioridade de animações:** jump > run > idle
- **Otimização:** Só muda animação quando necessário

### **4. Organização de Código:**
- **Separação de responsabilidades:** Input, física, animação
- **Funções específicas:** `_get_input()`, `_check_is_ground()`
- **Variáveis bem nomeadas:** `move_speed`, `jump_force`

### **5. Performance:**
- **onready:** Carrega referências uma vez
- **Verificação de mudança:** Só atualiza quando necessário
- **Delta time:** Movimento independente de FPS

### **6. Design Patterns:**
- **Component System:** Nós especializados (Sprite, Collision, etc.)
- **Observer Pattern:** Signals para comunicação
- **State Machine:** Sistema de animações baseado em estados

---

## FLUXO DE EXECUÇÃO

### **1. Inicialização:**
1. Godot carrega `Level_01.tscn`
2. Player é instanciado na posição (168, 9)
3. Câmera se torna ativa
4. Animação "idle" inicia automaticamente

### **2. Loop de Jogo (_physics_process):**
1. **Gravidade aplicada:** `velocity.y += gravity * delta`
2. **Input processado:** Calcula direção e velocidade
3. **Movimento executado:** `move_and_slide(velocity)`
4. **Chão verificado:** RayCasts checam colisões
5. **Animação atualizada:** Baseada no estado atual

### **3. Eventos Especiais:**
- **Pulo:** Detectado em `_input()`, modifica `velocity.y`
- **Fall Zone:** Trigger recarrega a cena
- **Mudança de direção:** Inverte sprite automaticamente

### **4. Renderização:**
- **Parallax:** Camadas movem em velocidades diferentes
- **Animações:** Frames trocam baseado no tempo
- **Câmera:** Segue player com suavização

---

## CONCLUSÃO

Este projeto demonstra conceitos fundamentais de desenvolvimento de jogos:
- **Física 2D** com gravidade e movimento
- **Sistema de input** responsivo
- **Animações** baseadas em estados
- **Detecção de colisão** precisa
- **Organização de código** limpa e eficiente
- **Efeitos visuais** com parallax scrolling

O código está bem estruturado, com separação clara de responsabilidades e uso adequado dos recursos do Godot. É um excelente exemplo de como implementar um personagem de plataforma 2D funcional e polido.