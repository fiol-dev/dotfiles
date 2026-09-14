#if (${PACKAGE_NAME} && ${PACKAGE_NAME} != "")package ${PACKAGE_NAME} #end

data class ${NAME}State(
    val paramOne: String = "default",
    val paramTwo: List<String> = emptyList(),
)