###########
### R-Code PP-MRD from: https://github.com/juliettelimozin/Multiple-trial-emulation-IPTW-MSM-CIs/blob/main/Code/Direct_boot_weight_func.R
#########

#Step 2 -- calculating survival probas with new model
Y_pred_treatment <- predict.glm(PP$model, 
                                fitting_data_treatment, 
                                type = "response")
Y_pred_control <- predict.glm(PP$model, 
                              fitting_data_control,
                              type = "response")

predicted_probas_PP <- fitting_data_treatment %>% 
  dplyr::mutate(predicted_proba_treatment = Y_pred_treatment,
                predicted_proba_control = Y_pred_control) %>% 
  dplyr::group_by(id, for_period) %>% 
  dplyr::mutate(cum_hazard_treatment = cumprod(1-predicted_proba_treatment),
                cum_hazard_control = cumprod(1-predicted_proba_control)) %>% 
  dplyr::ungroup() %>% 
  dplyr::group_by(followup_time) %>% 
  dplyr::summarise(survival_treatment = mean(cum_hazard_treatment),
                   survival_control = mean(cum_hazard_control),
                   survival_difference = survival_treatment - survival_control)

###########
### R-Code ITT-MRD from: https://github.com/juliettelimozin/Multiple-trial-emulation-IPTW-MSM-CIs/blob/a2d7b138798d1617e60f6a70a4719d45b5e58110/Code/Bootstrap%20survival%20proba%20ITT.R#L62
#########


Y_pred_ITT_treatment <- predict.glm(ITT$model$model, fitting_data_treatment, 
                                    type = "response")
Y_pred_ITT_control <- predict.glm(ITT$model$model, fitting_data_control, 
                                  type = "response")
predicted_probas_ITT <- fitting_data_treatment %>% 
  dplyr::mutate(predicted_proba_treatment = Y_pred_ITT_treatment,
                predicted_proba_control = Y_pred_ITT_control) %>% 
  dplyr::group_by(id, for_period) %>% 
  dplyr::mutate(cum_hazard_treatment = cumprod(1-predicted_proba_treatment),
                cum_hazard_control = cumprod(1-predicted_proba_control)) %>% 
  dplyr::ungroup() %>% 
  dplyr::group_by(followup_time) %>% 
  dplyr::summarise(survival_treatment = mean(cum_hazard_treatment),
                   survival_control = mean(cum_hazard_control),
                   survival_difference = survival_treatment - survival_control,
                   survival_ratio = survival_treatment/survival_control)