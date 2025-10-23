🧭 AWS HealthLake Implementation Plan – Cosight & Compass UOL
1. Contexto del Proyecto

Este plan describe el enfoque, las actividades, entregables, supuestos, exclusiones y riesgos asociados a la implementación de una plataforma Amazon HealthLake segura, escalable y conforme a GDPR/HIPAA, para la empresa Cosight, en colaboración con Compass UOL.

2. Alcance General del Proyecto

Objetivo:
Diseñar, implementar y validar un entorno AWS HealthLake conforme a GDPR, con prácticas de seguridad y monitoreo alineadas a las recomendaciones de AWS.

Enfoque:
El proyecto se desarrollará bajo un ciclo multi-fase, siguiendo buenas prácticas de IaC (Infrastructure as Code) y el marco de seguridad de AWS.

3. Fases del Proyecto y Entregables
🟦 Phase 1 – Discovery & Architecture

Objetivo: Comprender el entorno actual, los objetivos de negocio, los requisitos regulatorios y de seguridad, y diseñar la arquitectura base.

Actividades principales

Stakeholder Interviews (Workshops de Descubrimiento)

Entrevistas con representantes de negocio, arquitectura, seguridad y cumplimiento.

Identificación de casos de uso y objetivos del proyecto.

Definición del tipo y origen de los datos a manejar en HealthLake.

Revisión del entorno AWS actual

Auditoría de cuentas existentes, IAM, CloudTrail, Config, KMS, S3 y políticas de seguridad.

Identificación de brechas frente a GDPR y AWS Well-Architected Framework.

Diseño de arquitectura inicial

Definición de cuentas dedicadas (prod, non-prod, security).

Selección de la región eu-west-2 (Londres).

Diseño de red segura (VPC, subredes privadas, endpoints, NACLs, security groups).

Definición de controles de cumplimiento y lineamientos de IaC.

Validación de cumplimiento

Alineación de arquitectura con GDPR, HIPAA y políticas internas de Cosight.

Identificación de dependencias externas y procesos de aprobación.

Entregables

Documento de Arquitectura de Referencia.

Matriz de Requerimientos de Negocio y Regulatorios.

AWS Baseline Security & Compliance Assessment.

Plan de Implementación (roadmap técnico para fases siguientes).

🟩 Phase 2 – Infrastructure Setup

Objetivo: Provisionar la infraestructura base usando IaC.

Entregables:

AWS Accounts creadas bajo Organizations.

SCPs aplicados para restringir workloads a eu-west-2.

VPC, subredes privadas, endpoints, y buckets S3 seguros con políticas de ciclo de vida y Object Lock.

Servicios configurados: KMS, CloudTrail, AWS Config, Security Hub, GuardDuty, IAM, HealthLake.

Despliegue automatizado con Terraform o CloudFormation.

🟨 Phase 3 – Testing & Validation

Objetivo: Validar la correcta configuración y cumplimiento del entorno.

Entregables:

Pruebas de integración entre Security Hub, GuardDuty y HealthLake.

Validación de cumplimiento GDPR.

Simulación de failover.

Reporte de validación funcional y de seguridad.

🟧 Phase 4 – Monitoring & Optimization

Objetivo: Implementar visibilidad y control operacional.

Entregables:

CloudWatch alarms configuradas para HealthLake, Security Hub y GuardDuty.

Centralización de alertas en la cuenta de seguridad.

Validación de respuesta a eventos.

Recomendaciones de optimización.

🟥 Phase 5 – Documentation & Handover

Objetivo: Cierre formal del proyecto y transferencia de conocimiento.

Entregables:

Runbooks para HealthLake (import/export).

Diagramas de arquitectura “as-built”.

Documentación de IaC.

Sesión de transferencia de conocimiento (KT session).

Go-Live checklist.

4. Out of Scope

El proyecto no incluye:

ETL/ELT personalizados fuera del API de HealthLake.

Desarrollo de aplicaciones o modelado de datos personalizados.

Integración con herramientas de terceros.

Capacitaciones a usuarios finales.

Creación o migración de dashboards.

Integraciones con sistemas de pago.

Licenciamiento de software.

Soporte o troubleshooting de fuentes de datos externas.

Intervención en capas de aplicación, red, almacenamiento, SO o base de datos.

5. Assumptions

Cosight proporcionará los datos y definirá los esquemas a utilizar.

Cosight garantizará credenciales de acceso y disponibilidad de los servicios cloud.

Todas las aprobaciones (GDPR, seguridad, auditoría) serán gestionadas por Cosight.

Compass UOL implementará bajo prácticas IaC y guías de AWS.

6. Risks
Riesgo	                                        Impacto	        Mitigación
Retrasos en entrega de accesos o aprobaciones	Alto	        Establecer responsables y cronograma de acceso validado antes del kickoff.
Cambios regulatorios o de requisitos	        Medio	        Mantener revisión semanal de cambios regulatorios y control de versiones del diseño.
Dependencias de terceros o servicios externos	Medio	        Identificar proveedores externos durante Discovery.
Baja participación técnica de Cosight	        Alto	        Agendar reuniones semanales y sesiones de KT planificadas desde la Fase 1.