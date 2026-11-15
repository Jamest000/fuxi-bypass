#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/kprobes.h>
#include <linux/ptrace.h>
#include <linux/uaccess.h>

/* include/linux/soc/qcom/panel_event_notifier.h */
#define PANEL_EVENT_BLANK    1
#define PANEL_EVENT_UNBLANK  2
#define PANEL_EVENT_BLANK_LP 3

static struct kprobe kp = {
	.symbol_name = "panel_event_notifier_callback.05e8f898eeb33fbdb0358298849746d8",
};

static int handler_pre(struct kprobe *p, struct pt_regs *regs)
{
	u32 notif_type = 0;
	void *notif_ptr = (void *)regs->regs[1];

	if (!notif_ptr)
		return 0;

	if (copy_from_kernel_nofault(&notif_type, notif_ptr, sizeof(u32)) == 0) {
		if (notif_type == PANEL_EVENT_UNBLANK || notif_type == PANEL_EVENT_BLANK_LP) {
			u32 blank = PANEL_EVENT_BLANK;
			copy_to_kernel_nofault(notif_ptr, &blank, sizeof(u32));
		}
	}
	return 0;
}

static int __init fuxi_blank_bypass_init(void)
{
	kp.pre_handler = handler_pre;
	return register_kprobe(&kp);
}

static void __exit fuxi_blank_bypass_exit(void)
{
	unregister_kprobe(&kp);
}

module_init(fuxi_blank_bypass_init);
module_exit(fuxi_blank_bypass_exit);
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Bypass screen-on charging limit on Xiaomi 13 (fuxi)");
