C $Header$
C $Name$

#include "OCN_CPL_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP 0
C !ROUTINE: CPL_DIAGNOSTICS_FILL

C !INTERFACE:
      SUBROUTINE CPL_DIAGNOSTICS_FILL(
     I                     myTime, myIter, myThid )

C     !DESCRIPTION:
C     Fill-in diagnostics array for OCN_CPL variables

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "CPL_PARAMS.h"
#include "OCNCPL.h"

C     !INPUT PARAMETERS:
C     myTime   :: Current time of simulation ( s )
C     myIter   :: Current iteration number in simulation
C     myThid   :: my Thread Id number
      _RL     myTime
      INTEGER myIter, myThid
CEOP

#ifdef ALLOW_DIAGNOSTICS
C     !FUNCTIONS:
#ifdef ALLOW_THSICE
      LOGICAL  DIAGNOSTICS_IS_ON
      EXTERNAL DIAGNOSTICS_IS_ON
#endif /* ALLOW_THSICE */

C     !LOCAL VARIABLES:
#ifdef ALLOW_THSICE
      INTEGER bi,bj
      INTEGER i,j
      _RL tmpFld(1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL tmpFac
#endif /* ALLOW_THSICE */

      IF ( useDiagnostics ) THEN

        CALL DIAGNOSTICS_FILL( atmSLPr   , 'CPL_SLPr',
     I                          0, 1, 0, 1, 1, myThid )
        CALL DIAGNOSTICS_FILL( HeatFlux  , 'CPL_Qnet',
     I                          0, 1, 0, 1, 1, myThid )
        CALL DIAGNOSTICS_FILL( qShortWave, 'CPL_Qsw ',
     I                          0, 1, 0, 1, 1, myThid )
        CALL DIAGNOSTICS_FILL( tauX      , 'CPL_tauX',
     I                          0, 1, 0, 1, 1, myThid )
        CALL DIAGNOSTICS_FILL( tauY      , 'CPL_tauY',
     I                          0, 1, 0, 1, 1, myThid )
        CALL DIAGNOSTICS_FILL( FWFlux    , 'CPL_FWat',
     I                          0, 1, 0, 1, 1, myThid )
        CALL DIAGNOSTICS_FILL( iceSaltFlx, 'CPL_sFlx',
     I                          0, 1, 0, 1, 1, myThid )
        CALL DIAGNOSTICS_FILL( seaIceMass, 'CPL_iceM',
     I                          0, 1, 0, 1, 1, myThid )
#ifdef ALLOW_SALT_PLUME
        IF ( ocn_cplExch_SaltPl ) THEN
         CALL DIAGNOSTICS_FILL( saltPlmFlx_cpl, 'CPL_sPlm',
     I                          0, 1, 0, 1, 1, myThid )
        ENDIF
#endif /* ALLOW_SALT_PLUME */
#ifdef ALLOW_DIC
        IF ( ocn_cplExch_RunOff ) THEN
         CALL DIAGNOSTICS_FILL( RunOff_cpl, 'CPL_RnOf',
     I                          0, 1, 0, 1, 1, myThid )
        ENDIF
        IF ( ocn_cplExch_DIC ) THEN
         CALL DIAGNOSTICS_FILL( airCO2    , 'CPL_aCO2',
     I                          0, 1, 0, 1, 1, myThid )
         CALL DIAGNOSTICS_FILL( surfWSpeed, 'CPL_wSpd',
     I                          0, 1, 0, 1, 1, myThid )
        ENDIF
#endif /* ALLOW_DIC */
#if (defined ALLOW_DIC) || (defined ALLOW_THSICE)
        IF ( ( ocn_cplExch1W_sIce.AND.ocn_cplExch_DIC )
     &    .OR. ocn_cplExch2W_sIce ) THEN
         CALL DIAGNOSTICS_FILL( sIceFrac_cpl , 'CPL_icFr',
     I                          0, 1, 0, 1, 1, myThid )
        ENDIF
#endif /* ALLOW_DIC or ALLOW_THSICE */
#ifdef ALLOW_THSICE
        IF ( ocn_cplExch2W_sIce ) THEN
C      Ice-fraction weighted quantities:
         tmpFac = 1. _d 0
         CALL DIAGNOSTICS_FRACT_FILL(
     I                          sIceThick_cpl, sIceFrac_cpl,
     I                          tmpFac, 1, 'CPL_iceH',
     I                          0, 1, 0, 1, 1, myThid )
         CALL DIAGNOSTICS_FRACT_FILL(
     I                          sIceSnowH_cpl, sIceFrac_cpl,
     I                          tmpFac, 1, 'CPL_snwH',
     I                          0, 1, 0, 1, 1, myThid )

C      Ice-Volume weighted quantities:
         IF ( DIAGNOSTICS_IS_ON('CPL_Qic1',myThid) .OR.
     &        DIAGNOSTICS_IS_ON('CPL_Qic2',myThid) ) THEN
          DO bj=myByLo(myThid),myByHi(myThid)
           DO bi=myBxLo(myThid),myBxHi(myThid)

            DO j=1-OLy,sNy+OLy
             DO i=1-OLx,sNx+OLx
              tmpFld(i,j) = sIceFrac_cpl(i,j,bi,bj)
     &                    * sIceThick_cpl(i,j,bi,bj)
             ENDDO
            ENDDO
            CALL DIAGNOSTICS_FRACT_FILL(
     I                          sIceQ1_cpl(1-OLx,1-OLy,bi,bj),
     I                          tmpFld, tmpFac, 1, 'CPL_Qic1',
     I                          0, 1, 2,bi,bj, myThid )
            CALL DIAGNOSTICS_FRACT_FILL(
     I                          sIceQ2_cpl(1-OLx,1-OLy,bi,bj),
     I                          tmpFld, tmpFac, 1, 'CPL_Qic2',
     I                          0, 1, 2,bi,bj, myThid )

           ENDDO
          ENDDO
         ENDIF

        ENDIF
#endif /* ALLOW_THSICE */

      ENDIF

#endif /* ALLOW_DIAGNOSTICS */
      RETURN
      END
