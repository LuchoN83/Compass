# 🟦 Phase 1 – Discovery & Architecture  
**Duración total:** 2 semanas (10 días hábiles)  
**Proyecto:** AWS HealthLake Implementation – Cosight & Compass UOL  
**Responsable principal:** AWS Cloud Architect  

---

## 🎯 Objetivo General

Realizar el **descubrimiento técnico y de negocio** para diseñar la arquitectura base de **AWS HealthLake**, garantizando **cumplimiento GDPR/HIPAA**, alineamiento con **AWS Well-Architected Framework**, y generar los entregables necesarios para iniciar la **Fase 2 – Infrastructure Setup**.

---

## 🗓️ Cronograma General (2 Semanas)

| Semana | Enfoque principal | Objetivos clave | Entregables |
|--------|-------------------|-----------------|--------------|
| **Semana 1** | **Discovery y análisis** | Levantar información de negocio, seguridad y entorno actual AWS. | Cuestionario completo + informe de brechas inicial. |
| **Semana 2** | **Diseño y validación** | Diseñar arquitectura base, validar cumplimiento GDPR y definir roadmap técnico. | Documento de arquitectura + matriz de cumplimiento + roadmap técnico. |

---

## ⚙️ Estructura General de la Fase

| Etapa | Enfoque | Entregable principal |
|--------|----------|----------------------|
| 1️⃣ Kickoff y Plan de Trabajo | Alinear objetivos, accesos, roles y agenda. | Agenda y plan de ejecución (RACI). |
| 2️⃣ Requerimientos Críticos | Entrevistas rápidas con negocio, seguridad y datos. | Matriz de requerimientos y brechas. |
| 3️⃣ Auditoría Técnica AWS | Revisión del entorno actual, seguridad y cumplimiento. | AWS Baseline Security Assessment. |
| 4️⃣ Diseño de Arquitectura Base | Crear blueprint técnico y de seguridad. | Documento de Arquitectura (HLD). |
| 5️⃣ Validación y Roadmap | Validar cumplimiento GDPR y plan técnico de fases. | Matriz de cumplimiento + roadmap IaC. |

---

## 1️⃣ Kickoff y Plan de Trabajo  
**Duración:** 0.5 día

### 🎯 Objetivo
Alinear expectativas, confirmar plazos, responsables y definir el marco operativo del discovery.

### 🔍 Actividades
- Reunión de kickoff (Cosight + Compass UOL).  
- Confirmar **accesos AWS**, responsables técnicos y regulatorios.  
- Validar **alcance, supuestos y riesgos**.  
- Acordar formato de entregables y calendario de workshops.  

### 📄 Entregable
- **Plan de Ejecución** con:
  - Fechas clave y responsables (RACI).  
  - Lista de accesos requeridos.  
  - Validación de participantes y sesiones planificadas.

---

## 2️⃣ Levantamiento de Requerimientos Críticos  
**Duración:** 3 días (bloques de 2–3 horas con cada área)

### 🎯 Objetivo
Recolectar información crítica sobre negocio, seguridad, datos, cumplimiento y arquitectura actual.

### 🔍 Actividades
- Realizar entrevistas cortas con stakeholders clave: negocio, datos, seguridad, infraestructura y compliance.  
- Identificar flujos de datos, dependencias, regulaciones y sistemas externos.  
- Registrar requisitos en una matriz consolidada.

### 🧩 Preguntas Clave

| Tema | Preguntas | Responsable |
|------|------------|-------------|
| **Datos & Casos de Uso** | ¿Qué tipo de datos (FHIR, JSON, imágenes médicas)?<br>¿Qué volumen diario estiman?<br>¿Qué sistemas externos proveen datos? | Data Owner |
| **Regulación y Cumplimiento** | ¿Qué auditorías aplican (GDPR, HIPAA)?<br>¿Existen políticas de retención o borrado seguro? | Compliance Officer |
| **Seguridad** | ¿Cómo se gestionan IAM, KMS y cifrado?<br>¿Qué prácticas de MFA y roles existen? | Security Lead |
| **Infraestructura Actual AWS** | ¿Qué cuentas existen?<br>¿Cómo gestionan logging, monitoreo y costos? | Cloud Admin |
| **Operación y Soporte** | ¿Qué equipo operará HealthLake post-GoLive?<br>¿Qué herramientas de monitoreo usan (CloudWatch, Dynatrace)? | Ops Manager |

### 📄 Entregables
- **Matriz de Requerimientos (Negocio, Técnico y Regulatorio)**  
- **Lista de brechas iniciales** clasificadas por dominio (datos, seguridad, cumplimiento, infraestructura).

---

## 3️⃣ Auditoría Técnica del Entorno AWS  
**Duración:** 2 días

### 🎯 Objetivo
Auditar la configuración actual en AWS y detectar brechas respecto a buenas prácticas y cumplimiento GDPR.

### 🔍 Revisión técnica

| Dominio | Validaciones Clave |
|----------|--------------------|
| **Cuentas & Organizations** | Verificar estructura de cuentas (prod, non-prod, security) y uso de SCPs. |
| **Identidad (IAM)** | Revisar usuarios, roles, MFA, políticas y rotación de claves. |
| **Registro & Monitoreo** | Validar CloudTrail (multi-región), AWS Config y centralización de logs. |
| **Seguridad de Datos** | Confirmar cifrado KMS (CMK), Object Lock y ciclo de vida S3. |
| **Networking** | Validar VPC, subredes privadas, endpoints y ausencia de recursos públicos. |
| **Compliance** | Confirmar uso de Security Hub, GuardDuty y reglas de AWS Config activas. |

### 📄 Entregable
- **AWS Baseline Security & Compliance Assessment**, con:
  - Brechas detectadas.  
  - Nivel de madurez (por dominio).  
  - Recomendaciones prioritarias de remediación.

---

## 4️⃣ Diseño de Arquitectura Base (Blueprint Inicial)  
**Duración:** 3 días

### 🎯 Objetivo
Diseñar la arquitectura base del entorno HealthLake en AWS, considerando seguridad, cumplimiento y despliegue mediante IaC.

### 🔍 Lineamientos de Diseño

#### 🔸 Cuentas
- `cosight-prod`, `cosight-nonprod`, `cosight-security` bajo **AWS Organizations**.  

#### 🔸 Región
- **eu-west-2 (Londres)** para residencia de datos bajo GDPR.

#### 🔸 Red (Networking)
- VPC por entorno.  
- Subredes privadas con **VPC Endpoints** (S3, CloudWatch, KMS, STS).  
- Sin exposición pública.  

#### 🔸 Seguridad
- Cifrado en reposo con **AWS KMS CMK**.  
- Logging centralizado en S3 con **Object Lock**.  
- **Security Hub** y **GuardDuty** habilitados a nivel organizacional.  
- CloudTrail y AWS Config activos globalmente.  

#### 🔸 HealthLake
- **FHIR Datastore** con cifrado KMS.  
- **S3 buckets** para import/export de datos con ciclo de vida y retención.

#### 🔸 IaC (Infrastructure as Code)
- Despliegue con **Terraform** modularizado:
  - `network`
  - `security`
  - `healthlake`
  - `logging`

### 📄 Entregables
- **High-Level Design Diagram (Lógico y Físico)**  
- **Documento de Arquitectura de Referencia (HLD)** – máximo 10 páginas.  

---

## 5️⃣ Validación de Cumplimiento y Roadmap Técnico  
**Duración:** 1.5 días

### 🎯 Objetivo
Validar que el diseño cumple con GDPR y AWS Well-Architected Framework, y establecer la hoja de ruta de implementación (IaC y despliegue).

### 🔍 Actividades
- Mapear controles GDPR ↔ servicios AWS.  
- Validar residencia de datos, cifrado, accesos y logging.  
- Revisar dependencias externas (ETL, integraciones).  
- Definir plan técnico por fase (IaC y despliegue).  

### 📄 Entregables
- **Matriz de Cumplimiento y Riesgos (2–3 páginas).**  
- **Roadmap Técnico de Implementación (IaC).**  

---

## 🧱 Entregables Mínimos de la Fase 1

| Documento | Descripción | Prioridad |
|------------|-------------|------------|
| 🧩 **Matriz de Requerimientos de Negocio y Regulatorios** | Requisitos funcionales, técnicos y regulatorios documentados. | Alta |
| 🔒 **AWS Baseline Security & Compliance Assessment** | Auditoría del entorno AWS y brechas de seguridad. | Alta |
| 🏗️ **Documento de Arquitectura de Referencia (HLD)** | Diseño lógico y físico con componentes AWS. | Alta |
| ⚖️ **Matriz de Cumplimiento y Riesgos** | Controles GDPR ↔ AWS, mitigación y responsabilidades. | Media |
| 🧭 **Roadmap Técnico / Plan de Implementación** | Cronograma e hitos para IaC. | Media |

---

## 👥 Equipo Requerido

| Rol | Responsabilidad | Dedicación |
|------|-----------------|-------------|
| **AWS Cloud Architect** | Liderar discovery técnico, diseño de arquitectura y compliance mapping. | 100% |
| **AWS Security Engineer** | Auditoría de seguridad y cumplimiento, revisión de prácticas GDPR. | 50% |
| **Project Manager** | Seguimiento, documentación y coordinación. | 50% |
| **DevOps Engineer (IaC)** | Validar módulos Terraform/CloudFormation y dependencias. | 25% |
| **Data/Compliance Officer (Cosight)** | Aportar requerimientos de datos y revisiones regulatorias. | 25% |

---

## 🔑 Factores Críticos de Éxito

1. Acceso temprano a las cuentas AWS (**día 1–2**).  
2. Participación activa de los roles técnicos y de compliance del cliente.  
3. Entregables ejecutivos, concisos (≤10 páginas).  
4. Enfoque exclusivo en arquitectura, seguridad y cumplimiento (no desarrollo).  
5. Revisión intermedia (**día 7**) para validación ejecutiva.  

---

## ✅ Resultado Esperado al Final de las 2 Semanas

- **Blueprint de HealthLake aprobado** por Cosight.  
- **Auditoría del entorno AWS completada**, con brechas documentadas.  
- **Diseño técnico validado** conforme a GDPR y buenas prácticas AWS.  
- **Roadmap aprobado** para la ejecución de la Fase 2 – Infrastructure Setup.

---

> **© 2025 Compass UOL & Cosight**  
> Documento interno – Confidencial  
> *AWS HealthLake Implementation – Discovery & Architecture Phase v1.0*
