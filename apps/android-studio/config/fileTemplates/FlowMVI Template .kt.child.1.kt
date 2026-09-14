#if (${PACKAGE_NAME} && ${PACKAGE_NAME} != "") package ${PACKAGE_NAME} #end
import org.alabuga.builtcontrol.core.domain.error.DataError
import pro.respawn.flowmvi.api.MVIAction
import pro.respawn.flowmvi.api.MVIIntent
import pro.respawn.flowmvi.api.MVIState

data class ${NAME}State(
    val error: DataError? = null
) : MVIState

sealed interface ${NAME}Intent : MVIIntent {
    data object ClickedOn : ${NAME}Intent
}

sealed interface ${NAME}Action : MVIAction