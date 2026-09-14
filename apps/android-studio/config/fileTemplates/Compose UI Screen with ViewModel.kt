#if (${PACKAGE_NAME} && ${PACKAGE_NAME} != "") package ${PACKAGE_NAME} #end
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel

@Composable
fun ${NAME}Root(
    viewModel: ${NAME}ViewModel = viewModel()
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    
    ${NAME}Screen(
        state = state,
        onAction = viewModel::onAction
    )
}

@Composable
fun ${NAME}Screen(
    state: ${NAME}State,
    onAction: (${NAME}Action) -> Unit,
) {

}

@Preview
@Composable
private fun Preview() {
    ${PROJECT_NAME}Theme {
        ${NAME}Screen(
            state = ${NAME}State(),
            onAction = {}
        )
    }
}